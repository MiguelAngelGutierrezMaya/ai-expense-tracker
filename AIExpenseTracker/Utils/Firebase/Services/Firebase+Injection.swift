//
//  Firebase+Injection.swift
//  AIExpenseTracker
//
//  Created by Miguel Angel Gutierrez Maya on 6/06/24.
//

import Foundation
import Factory
import FirebaseFirestore
import FirebaseFirestoreSwift

/// Determines whether to use the Firebase Local Emulator Suite.
fileprivate func isPreviewRuntime() -> Bool {
    return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
}

extension Container {
    /// Determines whether to use the Firebase Local Emulator Suite.
    /// To use the local emulator, go to the active scheme, and add `-useEmulator YES`
    /// to the _Arguments Passed On Launch_ section.
    public var useEmulator: Factory<Bool> {
        Factory(self) {
            let value = UserDefaults.standard.bool(forKey: "useEmulator")
            return value
        }.singleton
    }
    
    public var firestore: Factory<Firestore> {
        Factory(self) {
            var environment: String = ""
            
            //if isPreviewRuntime() {
            if Container.shared.useEmulator() {
                let settings = Firestore.firestore().settings
                settings.host = "localhost:8080"
                settings.cacheSettings = MemoryCacheSettings()
                //        settings.cacheSettings = MemoryCacheSettings(
                //            garbageCollectorSettings: MemoryLRUGCSettings()
                //        )
                settings.isSSLEnabled = false
                environment = "to use the local emulator \(settings.host)"
                
                Firestore.firestore().settings = settings
            } else {
                environment = "to use the Firebase backend"
            }
            
            print("Firestore configured \(environment)")
            
            return Firestore.firestore()
        }.singleton
    }
}
