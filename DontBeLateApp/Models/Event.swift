//
//  Event.swift
//  DontBeLate
//
//  Created on 2025
//

import Foundation
import EventKit
import CoreLocation

struct EventModel: Identifiable, Hashable {
    let id: String
    let title: String
    let startDate: Date
    let endDate: Date
    let location: String?
    let hasLocation: Bool
    let notes: String?
    let calendar: String
    
    // Computed properties
    var shouldBlockApps: Bool {
        return startDate > Date()
    }
    
    var timeUntilEvent: TimeInterval {
        return startDate.timeIntervalSince(Date())
    }
    
    init(from ekEvent: EKEvent) {
        self.id = ekEvent.eventIdentifier
        self.title = ekEvent.title ?? "Untitled Event"
        self.startDate = ekEvent.startDate
        self.endDate = ekEvent.endDate
        self.location = ekEvent.location
        self.hasLocation = ekEvent.structuredLocation != nil || ekEvent.location != nil
        self.notes = ekEvent.notes
        self.calendar = ekEvent.calendar.title
    }
}

struct AppBlockRule: Codable, Identifiable {
    let id: UUID
    var eventId: String
    var blockedAppBundleIds: [String]
    var blockStartTime: Date
    var blockEndTime: Date
    var isActive: Bool
    var usesTrafficCalculation: Bool
    var travelTimeMinutes: Int?
    
    init(eventId: String, blockedAppBundleIds: [String], blockStartTime: Date, blockEndTime: Date, usesTrafficCalculation: Bool = false) {
        self.id = UUID()
        self.eventId = eventId
        self.blockedAppBundleIds = blockedAppBundleIds
        self.blockStartTime = blockStartTime
        self.blockEndTime = blockEndTime
        self.isActive = false
        self.usesTrafficCalculation = usesTrafficCalculation
        self.travelTimeMinutes = nil
    }
}

