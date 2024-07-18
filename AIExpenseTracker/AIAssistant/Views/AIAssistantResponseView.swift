//
//  AIAssistantResponseView.swift
//  AIExpenseTracker
//
//  Created by Miguel Angel Gutierrez Maya on 12/07/24.
//

import SwiftUI

struct AIAssistantResponseView: View {
    let response: AIAssistantResponse
    
    var body: some View {
        switch response.type {
        case .addExpenseLog(let props):
            AddExpenseLogView(
                props: props
            )
        case .listExpenses(let logs):
            ListExpensesLogsView(
                text: response.text,
                logs: logs
            )
        case .visualizeExpenses(let chartType, let options):
            VisualizeExpensesView(
                text: response.text,
                chartType: chartType,
                options: options
            )
        default:
            Text(response.text)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
        }
    }
}

struct AddExpenseLogView: View {
    let props: AddExpenseLogViewProperties
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Please select de confirm button before i add it to your expense list")
            Divider()
            LogItemView(log: props.log)
            Divider()
            switch props.userConfirmation {
            case .pending:
                if let confirmationCallback = props.confirmationCallback {
                    HStack {
                        Button("Confirm") {
                            confirmationCallback(true, props)
                        }
                        .buttonStyle(BorderedProminentButtonStyle())
                        
                        Button("Cancel", role: .destructive) {
                            confirmationCallback(false, props)
                        }
                        .buttonStyle(BorderedProminentButtonStyle())
                        .tint(.red)
                    }
                }
            case .confirmed:
                Button("Confirmed") {
                }
                .buttonStyle(BorderedProminentButtonStyle())
                .disabled(true)
                
                Text("Sure, I've added this log to your expense list")
            case .cancelled:
                Button("Cancel", role: .destructive) {}
                    .buttonStyle(BorderedProminentButtonStyle())
                    .tint(.red)
                    .disabled(true)
                
                Text("Ok, i won't add this log to your expense list")
            }
        }
    }
}

struct ListExpensesLogsView: View {
    let text: String
    let logs: [ExpenseLog]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(text)
            if logs.count > 0 {
                Divider()
                ForEach(logs) { log in
                    LogItemView(log: log)
                    Divider()
                }
            }
        }
    }
}

struct VisualizeExpensesView: View {
    
    let text: String
    let chartType: ChartType
    let options: [Option]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(text)
            
            if options.count > 0 {
                Divider()
                switch chartType {
                case .pie:
                    PieChartView(options: options)
                        .frame(
                            maxWidth: .infinity,
                            minHeight: 220
                        )
                case .bar:
                    BarChartView(options: options)
                        .frame(
                            maxWidth: .infinity,
                            minHeight: 220
                        )
                }
            }
        }
    }
}

#Preview {
    AIAssistantResponseView(
        response: .init(
            text: "Hello",
            type: .contentText
        )
    )
}
