//
//  DatabaseManager.swift
//  AIExpenseTracker
//
//  Created by Miguel Angel Gutierrez Maya on 16/06/24.
//

import FirebaseFirestore
import Factory
import Foundation

class DatabaseManager {
    /// Firestore instance
    @Injected(\.firestore) var firestore
    
    /// Singleton shared instance
    static let shared = DatabaseManager()
    
    private init() {}
    
    private (set) lazy var logsCollection: CollectionReference = {
        firestore.collection("logs")
    }()
    
    func get(completion: @escaping ([ExpenseLog]) -> Void) {
        firestore
            .collection("logs")
            .order(by: SortType.date.rawValue, descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error getting logs: \(error)")
                    completion([])
                } else {
                    let logs = snapshot?.documents.compactMap { document -> ExpenseLog? in
                        try? document.data(as: ExpenseLog.self)
                    } ?? []
                    completion(logs)
                }
            }
    }
    
    func add(log: ExpenseLog) {
        do {
            try logsCollection.document(log.id).setData(from: log)
        } catch {
            print("Error adding log: \(error)")
        }
    }
    
    func update(log: ExpenseLog) {
        logsCollection.document(log.id).updateData([
            "name": log.name,
            "amount": log.amount,
            "category": log.category,
            "date": log.date
        ])
    }
    
    func delete(log: ExpenseLog) {
        logsCollection.document(log.id).delete()
    }
}
