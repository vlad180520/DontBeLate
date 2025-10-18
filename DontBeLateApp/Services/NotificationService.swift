//
//  NotificationService.swift
//  DontBeLate
//
//  Created on 2025
//

import Foundation
import UserNotifications

class NotificationService: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationService()
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    override private init() {
        super.init()
        notificationCenter.delegate = self
        setupNotificationCategories()
    }
    
    // Setup notification categories with actions
    private func setupNotificationCategories() {
        // Blocking notification category
        let viewEventAction = UNNotificationAction(
            identifier: "VIEW_EVENT",
            title: "View Event",
            options: .foreground
        )
        
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE",
            title: "Snooze 5 min",
            options: []
        )
        
        let blockingCategory = UNNotificationCategory(
            identifier: "BLOCKING_NOTIFICATION",
            actions: [viewEventAction, snoozeAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )
        
        // Reminder category
        let viewAction = UNNotificationAction(
            identifier: "VIEW_REMINDER",
            title: "View",
            options: .foreground
        )
        
        let reminderCategory = UNNotificationCategory(
            identifier: "EVENT_REMINDER",
            actions: [viewAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )
        
        // Traffic alert category
        let leaveNowAction = UNNotificationAction(
            identifier: "LEAVE_NOW",
            title: "Start Navigation",
            options: .foreground
        )
        
        let trafficCategory = UNNotificationCategory(
            identifier: "TRAFFIC_ALERT",
            actions: [leaveNowAction, snoozeAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )
        
        notificationCenter.setNotificationCategories([blockingCategory, reminderCategory, trafficCategory])
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, 
                               willPresent notification: UNNotification, 
                               withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, 
                               didReceive response: UNNotificationResponse, 
                               withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle notification actions
        switch response.actionIdentifier {
        case "VIEW_EVENT", "VIEW_REMINDER", "LEAVE_NOW":
            print("User tapped notification action: \(response.actionIdentifier)")
            // App will open and show the event
        case "SNOOZE":
            print("User snoozed notification")
            // Could re-schedule notification for 5 minutes later
        default:
            break
        }
        
        completionHandler()
    }
    
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            completion(granted, error)
        }
    }
    
    func checkAuthorizationStatus(completion: @escaping (Bool) -> Void) {
        notificationCenter.getNotificationSettings { settings in
            completion(settings.authorizationStatus == .authorized)
        }
    }
    
    // Schedule notification for app blocking
    func scheduleAppBlockNotification(
        eventTitle: String,
        eventStartDate: Date,
        minutesBefore: Int,
        completion: @escaping (Bool) -> Void
    ) {
        let content = UNMutableNotificationContent()
        content.title = "Don't Be Late!"
        content.body = "The event '\(eventTitle)' will start soon. Your apps have been blocked until you're ready."
        content.sound = .default
        content.categoryIdentifier = "EVENT_REMINDER"
        
        // Calculate trigger time
        let triggerDate = Calendar.current.date(byAdding: .minute, value: -minutesBefore, to: eventStartDate)!
        
        guard triggerDate > Date() else {
            completion(false)
            return
        }
        
        let triggerComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
        
        let identifier = "event-\(eventTitle)-\(eventStartDate.timeIntervalSince1970)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    // Schedule notification with dynamic traffic-based timing
    func scheduleTrafficBasedNotification(
        eventTitle: String,
        eventStartDate: Date,
        travelTimeMinutes: Int,
        completion: @escaping (Bool) -> Void
    ) {
        let content = UNMutableNotificationContent()
        content.title = "Time to Leave!"
        content.body = "The event '\(eventTitle)' starts in \(travelTimeMinutes) minutes. Based on current traffic, you should leave now. Your apps have been blocked."
        content.sound = .default
        content.categoryIdentifier = "TRAFFIC_ALERT"
        
        // Add buffer time (extra 5 minutes for preparation)
        let totalMinutes = travelTimeMinutes + 5
        
        let triggerDate = Calendar.current.date(byAdding: .minute, value: -totalMinutes, to: eventStartDate)!
        
        guard triggerDate > Date() else {
            completion(false)
            return
        }
        
        let triggerComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
        
        let identifier = "traffic-\(eventTitle)-\(eventStartDate.timeIntervalSince1970)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    // Send immediate notification
    func sendImmediateNotification(title: String, body: String, badge: Int? = nil) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        if let badge = badge {
            content.badge = NSNumber(value: badge)
        }
        
        // Assign appropriate category based on title
        if title.contains("Blocked") {
            content.categoryIdentifier = "BLOCKING_NOTIFICATION"
        } else if title.contains("Unblocked") {
            content.categoryIdentifier = "EVENT_REMINDER"
        }
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error sending notification: \(error.localizedDescription)")
            } else {
                print("✅ Notification sent: \(title)")
            }
        }
    }
    
    // Schedule event reminder (separate from blocking notifications)
    func scheduleEventReminder(
        eventTitle: String,
        eventStartDate: Date,
        minutesBefore: Int,
        completion: @escaping (Bool) -> Void
    ) {
        let content = UNMutableNotificationContent()
        content.title = "📅 Upcoming Event Reminder"
        content.body = "'\(eventTitle)' starts in \(minutesBefore) minutes. Get ready!"
        content.sound = .default
        content.categoryIdentifier = "EVENT_REMINDER"
        
        // Calculate trigger time
        let triggerDate = Calendar.current.date(byAdding: .minute, value: -minutesBefore, to: eventStartDate)!
        
        guard triggerDate > Date() else {
            completion(false)
            return
        }
        
        let triggerComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
        
        let identifier = "reminder-\(eventTitle)-\(eventStartDate.timeIntervalSince1970)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling reminder: \(error.localizedDescription)")
                completion(false)
            } else {
                print("✅ Reminder scheduled for: \(eventTitle)")
                completion(true)
            }
        }
    }
    
    // Cancel notification
    func cancelNotification(identifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    // Cancel all notifications
    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
    
    // Get pending notifications
    func getPendingNotifications(completion: @escaping ([UNNotificationRequest]) -> Void) {
        notificationCenter.getPendingNotificationRequests { requests in
            completion(requests)
        }
    }
}

