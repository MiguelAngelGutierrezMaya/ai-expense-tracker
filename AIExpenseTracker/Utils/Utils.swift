//
//  Utils.swift
//  AIExpenseTracker
//
//  Created by Miguel Angel Gutierrez Maya on 16/06/24.
//

import Foundation

struct Utils {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.isLenient = true
        formatter.numberStyle = .currency
        return formatter
    }()
}
