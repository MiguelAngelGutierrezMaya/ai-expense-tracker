//
//  FunctionManager.swift
//  AIExpenseTracker
//
//  Created by Miguel Angel Gutierrez Maya on 15/07/24.
//

import Foundation
import FirebaseFirestore
import ChatGPTSwift

class FunctionManager {
    let api: ChatGPTAPI
    let db = DatabaseManager.shared
    var addLogConfirmationCallback: AddExpenseLogConfirmationCallback?
    
    static let currentDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    let jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .custom({ decoder in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)
            guard let date = FunctionManager.currentDateFormatter.date(from: dateStr) else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Cannot decode date string \(dateStr)"
                )
            }
            return date
        })
        return jsonDecoder
    }()
    
    var systemText: String {
        return "You're expert of tracking and managing expenses log. Don't make assumptions about what values to plug into functions. Ask for clarification if a user request is ambiguous. Current date is \(Self.currentDateFormatter.string(from: .now))"
    }
    
    init(apiKey: String) {
        self.api = .init(apiKey: apiKey)
    }
    
    func prompt(
        _ prompt: String,
        model: ChatGPTModel = .gpt_hyphen_4o,
        messageID: UUID? = nil
    ) async throws -> AIAssistantResponse {
        do {
            let message = try await api.callFunction(
                prompt: prompt,
                tools: tools,
                model: model,
                systemText: systemText
            )
            try Task.checkCancellation()
            
            if let toolCall = message.tool_calls?.first,
               let functionType = AIAssistantFunctionType(rawValue: toolCall.function.name),
               let argumentData = toolCall.function.arguments.data(using: .utf8) {
                switch functionType {
                case .addExpenseLog:
                    guard let addLogConfirmationCallback else {
                        throw "Confirmation callback not set"
                    }
                    guard let addExpenseLogArgs = try? self.jsonDecoder.decode(AddExpenseLogArgs.self, from: argumentData) else {
                        throw "Failed to parse function arguments \(toolCall.function.name) \(toolCall.function.arguments)"
                    }
                    let log = ExpenseLog(
                        id: UUID().uuidString,
                        name: addExpenseLogArgs.title,
                        category: addExpenseLogArgs.category,
                        amount: addExpenseLogArgs.amount,
                        currency: addExpenseLogArgs.currency ?? "USD",
                        date: addExpenseLogArgs.date ?? .now
                    )
                    
                    // db.add(log: log)
                    
                    return .init(
                        text: "Please select the confirm button before i add it to your expense list",
                        type: .addExpenseLog(
                            .init(
                                log: log,
                                messageID: messageID,
                                userConfirmation: .pending,
                                confirmationCallback: addLogConfirmationCallback
                            )
                        )
                    )
                    
                case .listExpenses:
                    guard let listExpenseArgs = try? self.jsonDecoder.decode(ListExpenseArgs.self, from: argumentData) else {
                        throw "Failed to parse function arguments \(toolCall.function.name) \(toolCall.function.arguments)"
                    }
                    let query = getQuery(args: listExpenseArgs)
                    let docs = try await query.getDocuments()
                    let logs = try docs.documents.map { try $0.data(as: ExpenseLog.self) }
                    
                    let text: String
                    
                    if listExpenseArgs.isDateFilterExist {
                        if logs.isEmpty {
                            text = "You don't have any expenses at given date"
                        } else {
                            text = "Sure, here's the list of your expenses with total sum of \(Utils.numberFormatter.string(from: NSNumber(value: logs.reduce(0, { $0 + $1.amount }))) ?? "")"
                        }
                    } else {
                        if logs.isEmpty {
                            text = "You don't have any recent expenses"
                        } else {
                            text = "Sure, here's the list of your last \(logs.count) expenses with total sum of \(Utils.numberFormatter.string(from: NSNumber(value: logs.reduce(0, { $0 + $1.amount }))) ?? "")"
                        }
                    }
                    
                    return .init(text: text, type: .listExpenses(logs))
                    
                case .visualizeExpenses:
                    guard let visualizeExpenseArgs = try? self.jsonDecoder.decode(VisualizeExpenseArgs.self, from: argumentData) else {
                        throw "Failed to parse function arguments \(toolCall.function.name) \(toolCall.function.arguments)"
                    }
                    
                    let query = getQuery(args: .init(
                        date: visualizeExpenseArgs.date,
                        startDate: visualizeExpenseArgs.startDate,
                        endDate: visualizeExpenseArgs.endDate,
                        category: nil,
                        sortOrder: nil,
                        quantityOfLogs: nil
                    ))
                    
                    let docs = try await query.getDocuments()
                    let logs = try docs.documents.map { try $0.data(as: ExpenseLog.self) }
                    
                    var categorySumDict = [Category: Double]()
                    logs.forEach { log in
                        categorySumDict.updateValue(
                            (categorySumDict[log.categoryEnum] ?? 0) + log.amount,
                            forKey: log.categoryEnum
                        )
                    }
                    
                    let chartOptions = categorySumDict.map {
                        Option(category: $0.key, amount: $0.value)
                    }
                    
                    return .init(
                        text: "Sure, here's the visualization of your expenses for each category",
                        type: .visualizeExpenses(visualizeExpenseArgs.chartTypeEnum, chartOptions)
                    )
                    
//                default:
//                    var text = "Function Name: \(toolCall.function.name)"
//                    text += "\nArgs: \(toolCall.function.arguments)"
//                    return .init(text: text, type: .contentText)
                }
            } else if let message = message.content {
                api.appendToHistoryList(
                    userText: prompt,
                    responseText: message
                )
                return .init(text: message, type: .contentText)
            } else {
                throw "Invalid response"
            }
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
    
    func getQuery(args: ListExpenseArgs) -> Query {
        var filters = [Filter]()
        if let startDate = args.startDate,
            let endDate = args.endDate {
            filters.append(
                .whereField(
                    "date",
                    isGreaterOrEqualTo: startDate.startOfDay
                )
            )
            filters.append(
                .whereField(
                    "date",
                    isLessThanOrEqualTo: endDate.endOfDay
                )
            )
        } else if let date = args.date {
            filters.append(
                .whereField(
                    "date",
                    isGreaterOrEqualTo: date.startOfDay
                )
            )
            filters.append(
                .whereField(
                    "date",
                    isLessThanOrEqualTo: date.endOfDay
                )
            )
        }
        
        if let category = args.category {
            filters.append(
                .whereField("category", isEqualTo: category)
            )
        }
        
        var query = db.logsCollection.whereFilter(.andFilter(filters))
        let sortOrder = SortOrder(rawValue: args.sortOrder ?? "") ?? .descending
        query = query.order(by: "date", descending: sortOrder == .descending)
        
        if args.isDateFilterExist {
            if let quantityOfLogs = args.quantityOfLogs {
                query = query.limit(to: quantityOfLogs)
            }
        } else {
            let quantityOfLogs = args.quantityOfLogs ?? 100
            query = query.limit(to: quantityOfLogs)
        }
        
        return query
    }
}
