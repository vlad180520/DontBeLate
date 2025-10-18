//
//  AppState.swift
//  DontBeLate
//
//  Created on 2025
//

import Foundation
import Combine

class AppState: ObservableObject {
    @Published var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        }
    }
    
    @Published var isCalendarAuthorized = false
    @Published var isLocationAuthorized = false
    @Published var isNotificationAuthorized = false
    
    let calendarService = CalendarService.shared
    let locationService = LocationService.shared
    let notificationService = NotificationService.shared
    let eventMonitor = EventMonitor.shared
    
    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
    
    func initialize() {
        if hasCompletedOnboarding {
            eventMonitor.startMonitoring()
        }
    }
    
    // Async initialization for better performance
    @MainActor
    func initializeApp() async {
        await checkPermissions()
        initialize()
    }
    
    @MainActor
    func checkPermissions() async {
        // Check all permissions concurrently
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                self.calendarService.checkAuthorizationStatus { authorized in
                    Task { @MainActor in
                        self.isCalendarAuthorized = authorized
                    }
                }
            }
            
            group.addTask {
                self.locationService.checkAuthorizationStatus { authorized in
                    Task { @MainActor in
                        self.isLocationAuthorized = authorized
                    }
                }
            }
            
            group.addTask {
                self.notificationService.checkAuthorizationStatus { authorized in
                    Task { @MainActor in
                        self.isNotificationAuthorized = authorized
                    }
                }
            }
        }
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        eventMonitor.startMonitoring()
    }
}

