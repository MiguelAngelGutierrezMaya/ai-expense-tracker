//
//  ExpenseReceiptScannerView.swift
//  AIExpenseTracker
//
//  Created by Miguel Angel Gutierrez Maya on 20/07/24.
//

import AIReceiptScanner
import SwiftUI

struct ExpenseReceiptScannerView: View {
    
    @State var scanStatus: ScanStatus = .idle
    @State var addReceiptToExpenseSheetItem: SuccessScanResult?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        ReceiptPickerScannerView(
            apiKey: Private.apiKey,
            scanStatus: $scanStatus
        )
        .sheet(item: $addReceiptToExpenseSheetItem) { item in
            AddReceiptToExpenseConfirmationView(
                vm: .init(scanResult: item)
            )
            .frame(
                minWidth: horizontalSizeClass == .regular ? 960 : nil,
                minHeight: horizontalSizeClass == .regular ? 512 : nil
            )
        }
        .navigationTitle("XCA AI Receipt Scanner")
#if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if let scanResult = scanStatus.scanResult {
                    Button {
                        addReceiptToExpenseSheetItem = scanResult
                    } label: {
#if os(macOS)
                        HStack {
                            Image(systemName: "plus")
                                .symbolRenderingMode(.monochrome)
                                .tint(.accentColor)
                            Text("Add to Expenses")
                        }
#else
                        Text("Add to Expenses")
#endif
                    }
                }
            }
        }
    }
}

//#Preview {
//    ExpenseReceiptScannerView()
//}
