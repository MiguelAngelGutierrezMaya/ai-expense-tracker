//
//  AIExpenseTrackerApp.swift
//  AIExpenseTracker
//
//  Created by Miguel Angel Gutierrez Maya on 2/06/24.
//

import SwiftUI

@main
struct AIExpenseTrackerApp: App {
    
#if os(macOS)
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate
#else
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
#endif
    
    init() {
#if os(macOS)
        appDelegate.initFirebase() // Fixing problem because view is initializing before delegate
#endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
#if os(macOS)
                .frame(minWidth: 729, minHeight: 480)
#endif
        }
#if os(macOS)
        .windowResizability(.contentMinSize)
#endif
    }
}
