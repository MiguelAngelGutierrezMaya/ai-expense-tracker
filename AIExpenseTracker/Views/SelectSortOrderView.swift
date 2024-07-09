//
//  SelectSortOrderView.swift
//  AIExpenseTracker
//
//  Created by Miguel Angel Gutierrez Maya on 17/06/24.
//

import SwiftUI

struct SelectSortOrderView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Binding var sortType: SortType
    @Binding var sortOrder: SortOrder
    
    private let sortTypes = SortType.allCases
    private let sortOrders = SortOrder.allCases
    
    var body: some View {
        HStack {
#if !os(macOS)
            Text("Sort By")
#endif
            Picker(
                selection: $sortType,
                label: Text("Sort By")) {
                    ForEach(sortTypes, id: \.self) { sortType in
                        if horizontalSizeClass == .compact {
                            Image(
                                systemName: sortType.systemNameIcon
                            )
                            .tag(sortType)
                        } else {
                            Text(sortType.rawValue.capitalized)
                                .tag(sortType)
                        }
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            
            
#if !os(macOS)
            Text("Order By")
#endif
            Picker(
                selection: $sortOrder,
                label: Text("Order By")) {
                    ForEach(sortOrders, id: \.self) { order in
                        if horizontalSizeClass == .compact {
                            Image(
                                systemName: order == .ascending ? "arrow.up" : "arrow.down"
                            )
                            .tag(order)
                        } else {
                            Text(order.rawValue.capitalized)
                                .tag(order)
                        }
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
        }
        .padding()
        .frame(height: 64)
    }
}

struct SelectSortOrderView_Previews: PreviewProvider {
    static var previews: some View {
        @State var vm = LogListViewModel()
        
        return SelectSortOrderView(
            sortType: $vm.sortType,
            sortOrder: $vm.sortOrder
        )
    }
}

//#Preview {
//    SelectSortOrderView()
//}
