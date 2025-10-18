//
//  DontBeLateApp.swift
//  DontBeLate
//
//  Created on 2025
//

import SwiftUI
import UserNotifications

@main
struct DontBeLateApp: App {
    @StateObject private var appState = AppState()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        // Request notification permissions on app launch
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .onAppear {
                    appState.initialize()
                }
        }
    }
}

// App Delegate for background tasks
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Register for background tasks
        BackgroundTaskManager.shared.registerBackgroundTasks()
        
        return true
    }
}

