//
//  EventConfiguration.swift
//  DontBeLate
//
//  Created on 2025
//

import Foundation

// Per-event configuration for app blocking
struct EventConfiguration: Codable, Identifiable {
    let id: UUID
    let eventId: String
    let eventTitle: String
    var blockedAppBundleIds: [String]
    var minutesBeforeEvent: Int
    var isEnabled: Bool
    var useTrafficTiming: Bool
    
    init(eventId: String, eventTitle: String, blockedAppBundleIds: [String] = [], minutesBeforeEvent: Int = 15, isEnabled: Bool = true, useTrafficTiming: Bool = false) {
        self.id = UUID()
        self.eventId = eventId
        self.eventTitle = eventTitle
        self.blockedAppBundleIds = blockedAppBundleIds
        self.minutesBeforeEvent = minutesBeforeEvent
        self.isEnabled = isEnabled
        self.useTrafficTiming = useTrafficTiming
    }
}

// Manager for event configurations
class EventConfigurationManager: ObservableObject {
    static let shared = EventConfigurationManager()
    
    @Published var configurations: [String: EventConfiguration] = [:]
    
    private let userDefaultsKey = "eventConfigurations"
    
    private init() {
        loadConfigurations()
    }
    
    func getConfiguration(for eventId: String) -> EventConfiguration? {
        return configurations[eventId]
    }
    
    func saveConfiguration(_ config: EventConfiguration) {
        configurations[config.eventId] = config
        persistConfigurations()
    }
    
    func removeConfiguration(for eventId: String) {
        configurations.removeValue(forKey: eventId)
        persistConfigurations()
    }
    
    private func loadConfigurations() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let decoded = try? JSONDecoder().decode([String: EventConfiguration].self, from: data) else {
            return
        }
        configurations = decoded
    }
    
    private func persistConfigurations() {
        if let encoded = try? JSONEncoder().encode(configurations) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
}

