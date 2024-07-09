//
//  AppDelegate.swift
//  AIExpenseTracker
//
//  Created by Miguel Angel Gutierrez Maya on 6/06/24.
//

import Firebase
import FirebaseFirestore
import Foundation

#if os(macOS)
import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillFinishLaunching(_ notification: Notification) {
        // setupFirebase()
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // setupFirebase()
    }
    
    func initFirebase() {
        setupFirebase()
    }
}


#else
import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        setupFirebase()
        return true
    }
}

#endif

//fileprivate func isPreviewRuntime() -> Bool {
//    return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
//}

fileprivate func setupFirebase() {
    FirebaseApp.configure()
    
//    if isPreviewRuntime() {
//        let settings = Firestore.firestore().settings
//        settings.host = "localhost:8080"
//        // settings.isPersistenceEnabled = false
//        settings.cacheSettings = MemoryCacheSettings(
//            garbageCollectorSettings: MemoryLRUGCSettings()
//        )
//        settings.isSSLEnabled = false
//        Firestore.firestore().settings = settings
//    }
}
