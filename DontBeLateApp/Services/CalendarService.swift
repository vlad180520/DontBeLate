//
//  CalendarService.swift
//  DontBeLate
//
//  Created on 2025
//

import Foundation
import EventKit
import Combine

class CalendarService: ObservableObject {
    static let shared = CalendarService()
    
    private let eventStore = EKEventStore()
    private var isAuthorized = false
    
    // Publisher for calendar changes
    let calendarDidChange = PassthroughSubject<Void, Never>()
    
    private init() {
        // Observe calendar changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(calendarChanged),
            name: .EKEventStoreChanged,
            object: eventStore
        )
    }
    
    @objc private func calendarChanged() {
        print("📅 Calendar changed - syncing...")
        calendarDidChange.send()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // Request calendar access
    func requestAccess(completion: @escaping (Bool, Error?) -> Void) {
        if #available(iOS 17.0, *) {
            eventStore.requestFullAccessToEvents { granted, error in
                self.isAuthorized = granted
                completion(granted, error)
            }
        } else {
            eventStore.requestAccess(to: .event) { granted, error in
                self.isAuthorized = granted
                completion(granted, error)
            }
        }
    }
    
    // Check authorization status
    func checkAuthorizationStatus(completion: @escaping (Bool) -> Void) {
        let status = EKEventStore.authorizationStatus(for: .event)
        
        switch status {
        case .authorized, .fullAccess:
            isAuthorized = true
            completion(true)
        case .notDetermined:
            requestAccess { granted, _ in
                completion(granted)
            }
        default:
            isAuthorized = false
            completion(false)
        }
    }
    
    // Fetch upcoming events
    func fetchUpcomingEvents(daysAhead: Int = 7, completion: @escaping ([EventModel]) -> Void) {
        guard isAuthorized else {
            completion([])
            return
        }
        
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: daysAhead, to: startDate)!
        
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        let events = eventStore.events(matching: predicate)
        
        let eventModels = events.map { EventModel(from: $0) }
        completion(eventModels)
    }
    
    // Fetch events for a specific date
    func fetchEvents(for date: Date, completion: @escaping ([EventModel]) -> Void) {
        guard isAuthorized else {
            completion([])
            return
        }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = eventStore.predicateForEvents(withStart: startOfDay, end: endOfDay, calendars: nil)
        let events = eventStore.events(matching: predicate)
        
        let eventModels = events.map { EventModel(from: $0) }
        completion(eventModels)
    }
    
    // Get event by ID
    func getEvent(by eventId: String) -> EventModel? {
        guard let ekEvent = eventStore.event(withIdentifier: eventId) else {
            return nil
        }
        return EventModel(from: ekEvent)
    }
    
    // Get raw EKEvent by ID
    func getEKEvent(by eventId: String) -> EKEvent? {
        return eventStore.event(withIdentifier: eventId)
    }
    
    // Get location coordinates from event
    func getEventLocation(eventId: String) -> (latitude: Double, longitude: Double)? {
        guard let ekEvent = eventStore.event(withIdentifier: eventId),
              let structuredLocation = ekEvent.structuredLocation,
              let geoLocation = structuredLocation.geoLocation else {
            return nil
        }
        
        return (geoLocation.coordinate.latitude, geoLocation.coordinate.longitude)
    }
}

