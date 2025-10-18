//
//  UserSettings.swift
//  DontBeLate
//
//  Created on 2025
//

import Foundation
import FamilyControls
import ManagedSettings

class UserSettings: ObservableObject {
    static let shared = UserSettings()
    
    @Published var defaultPreEventMinutes: Int {
        didSet {
            UserDefaults.standard.set(defaultPreEventMinutes, forKey: "defaultPreEventMinutes")
        }
    }
    
    // Store actual Application tokens from FamilyActivityPicker
    // ApplicationToken is the correct type (Token<Application>)
    @Published var selectedAppsTokens: Set<ApplicationToken> = [] {
        didSet {
            // Update legacy bundle IDs for backward compatibility
            blockedAppBundleIds = Array(selectedAppsTokens.map { _ in "token" })
            print("✅ Saved \(selectedAppsTokens.count) app tokens")
        }
    }
    
    @Published var blockedAppBundleIds: [String] {
        didSet {
            UserDefaults.standard.set(blockedAppBundleIds, forKey: "blockedAppBundleIds")
        }
    }
    
    @Published var enableTrafficCalculation: Bool {
        didSet {
            UserDefaults.standard.set(enableTrafficCalculation, forKey: "enableTrafficCalculation")
        }
    }
    
    @Published var enableNotifications: Bool {
        didSet {
            UserDefaults.standard.set(enableNotifications, forKey: "enableNotifications")
        }
    }
    
    @Published var autoBlockEnabled: Bool {
        didSet {
            UserDefaults.standard.set(autoBlockEnabled, forKey: "autoBlockEnabled")
        }
    }
    
    @Published var preferredTransportType: TransportType {
        didSet {
            UserDefaults.standard.set(preferredTransportType.rawValue, forKey: "preferredTransportType")
        }
    }
    
    private init() {
        self.defaultPreEventMinutes = UserDefaults.standard.object(forKey: "defaultPreEventMinutes") as? Int ?? 15
        self.blockedAppBundleIds = UserDefaults.standard.stringArray(forKey: "blockedAppBundleIds") ?? []
        self.enableTrafficCalculation = UserDefaults.standard.object(forKey: "enableTrafficCalculation") as? Bool ?? true
        self.enableNotifications = UserDefaults.standard.object(forKey: "enableNotifications") as? Bool ?? true
        self.autoBlockEnabled = UserDefaults.standard.object(forKey: "autoBlockEnabled") as? Bool ?? true
        
        let transportRaw = UserDefaults.standard.string(forKey: "preferredTransportType") ?? "automobile"
        self.preferredTransportType = TransportType(rawValue: transportRaw) ?? .automobile
    }
}

enum TransportType: String, CaseIterable, Codable {
    case automobile = "automobile"
    case walking = "walking"
    case transit = "transit"
    
    var displayName: String {
        switch self {
        case .automobile: return "Car"
        case .walking: return "Walking"
        case .transit: return "Public Transit"
        }
    }
    
    var icon: String {
        switch self {
        case .automobile: return "car.fill"
        case .walking: return "figure.walk"
        case .transit: return "bus.fill"
        }
    }
}

struct BlockedApp: Identifiable, Codable {
    let id: UUID
    let bundleId: String
    let name: String
    let icon: String
    
    init(bundleId: String, name: String, icon: String = "app.fill") {
        self.id = UUID()
        self.bundleId = bundleId
        self.name = name
        self.icon = icon
    }
}

