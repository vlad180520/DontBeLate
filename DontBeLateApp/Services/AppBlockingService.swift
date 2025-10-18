//
//  AppBlockingService.swift
//  DontBeLate
//
//  Created on 2025
//

import Foundation
import FamilyControls
import ManagedSettings
import DeviceActivity

class AppBlockingService: ObservableObject {
    static let shared = AppBlockingService()
    
    private let authorizationCenter = AuthorizationCenter.shared
    @Published var isAuthorized = false
    
    private init() {}
    
    // Request Screen Time API authorization
    func requestAuthorization() async throws {
        do {
            try await authorizationCenter.requestAuthorization(for: .individual)
            await MainActor.run {
                self.isAuthorized = true
            }
        } catch {
            await MainActor.run {
                self.isAuthorized = false
            }
            throw error
        }
    }
    
    // Check if authorized
    func checkAuthorization() -> Bool {
        switch authorizationCenter.authorizationStatus {
        case .approved:
            isAuthorized = true
            return true
        default:
            isAuthorized = false
            return false
        }
    }
    
    // Block specific apps using ApplicationToken objects
    func blockApps(appTokens: Set<ApplicationToken>, until endDate: Date) {
        guard isAuthorized else {
            print("⚠️ Not authorized to block apps - Screen Time permission required")
            return
        }
        
        guard !appTokens.isEmpty else {
            print("⚠️ No apps to block")
            return
        }
        
        // ACTUALLY BLOCK APPS using ManagedSettings
        #if !targetEnvironment(simulator)
        if #available(iOS 16.0, *) {
            let store = ManagedSettingsStore()
            
            // ✅ ONLY BLOCK SPECIFIC APPS - NOT CATEGORIES
            // This ensures only the user-selected apps are blocked (e.g., Instagram only)
            // NOT all apps in social media category
            store.shield.applications = appTokens
            
            // DON'T block categories - we want specific apps only
            store.shield.applicationCategories = nil
            
            print("🔒 BLOCKING NOW: \(appTokens.count) SPECIFIC app\(appTokens.count == 1 ? "" : "s") being blocked!")
            print("📱 Apps will be shielded with Screen Time overlay until: \(endDate)")
            print("✅ Blocking is ACTIVE - ONLY selected apps are blocked, not categories!")
        }
        #else
        print("📱 Simulator: App blocking not available (test on real device)")
        #endif
    }
    
    // Legacy support for bundle IDs (backward compatibility)
    func blockApps(bundleIds: [String], until endDate: Date) {
        // Use the new token-based system
        let tokens = UserSettings.shared.selectedAppsTokens
        if !tokens.isEmpty {
            blockApps(appTokens: tokens, until: endDate)
        } else {
            print("⚠️ No app tokens available. Please select apps using the app picker.")
        }
    }
    
    // Unblock apps (bundleIds parameter kept for backward compatibility but not used)
    func unblockApps(bundleIds: [String] = []) {
        guard isAuthorized else {
            print("Not authorized to unblock apps")
            return
        }
        
        // ACTUALLY UNBLOCK APPS by clearing the shield
        #if !targetEnvironment(simulator)
        if #available(iOS 16.0, *) {
            let store = ManagedSettingsStore()
            
            // Clear the shield - apps are now accessible
            store.shield.applications = nil
            store.shield.applicationCategories = nil
            
            print("✅ UNBLOCKING NOW: Apps are accessible again!")
            print("📱 Screen Time shield has been removed")
        }
        #else
        print("📱 Simulator: App unblocking not available")
        #endif
    }
    
    // Get currently blocked apps
    func getBlockedApps() -> [String] {
        guard let rules = loadBlockRules() else {
            return []
        }
        
        let activeRules = rules.filter { $0.endTime > Date() }
        return activeRules.flatMap { $0.bundleIds }
    }
    
    // Save block rule to UserDefaults
    private func saveBlockRule(_ rule: AppBlockingRule) {
        var rules = loadBlockRules() ?? []
        rules.append(rule)
        
        if let encoded = try? JSONEncoder().encode(rules) {
            UserDefaults.standard.set(encoded, forKey: "blockRules")
        }
    }
    
    // Load block rules
    private func loadBlockRules() -> [AppBlockingRule]? {
        guard let data = UserDefaults.standard.data(forKey: "blockRules"),
              let rules = try? JSONDecoder().decode([AppBlockingRule].self, from: data) else {
            return nil
        }
        return rules
    }
    
    // Remove block rule
    private func removeBlockRule(for bundleIds: [String]) {
        guard var rules = loadBlockRules() else { return }
        
        rules.removeAll { rule in
            Set(rule.bundleIds).intersection(Set(bundleIds)).count > 0
        }
        
        if let encoded = try? JSONEncoder().encode(rules) {
            UserDefaults.standard.set(encoded, forKey: "blockRules")
        }
    }
}

// MARK: - Supporting Models
struct AppBlockingRule: Codable {
    let bundleIds: [String]
    let startTime: Date
    let endTime: Date
}

// MARK: - Common App Bundle IDs
extension AppBlockingService {
    static let commonApps: [BlockedApp] = [
        BlockedApp(bundleId: "com.burbn.instagram", name: "Instagram", icon: "camera.fill"),
        BlockedApp(bundleId: "com.facebook.Facebook", name: "Facebook", icon: "f.circle.fill"),
        BlockedApp(bundleId: "com.atebits.Tweetie2", name: "X (Twitter)", icon: "bird"),
        BlockedApp(bundleId: "com.google.chrome.ios", name: "Chrome", icon: "globe"),
        BlockedApp(bundleId: "com.toyopagroup.picaboo", name: "Snapchat", icon: "camera.macro"),
        BlockedApp(bundleId: "com.zhiliaoapp.musically", name: "TikTok", icon: "music.note"),
        BlockedApp(bundleId: "ph.telegra.Telegraph", name: "Telegram", icon: "paperplane.fill"),
        BlockedApp(bundleId: "net.whatsapp.WhatsApp", name: "WhatsApp", icon: "message.fill"),
        BlockedApp(bundleId: "com.google.Gmail", name: "Gmail", icon: "envelope.fill"),
        BlockedApp(bundleId: "com.reddit.Reddit", name: "Reddit", icon: "text.bubble.fill"),
        BlockedApp(bundleId: "com.getdropbox.Dropbox", name: "Dropbox", icon: "folder.fill"),
        BlockedApp(bundleId: "com.spotify.client", name: "Spotify", icon: "music.note.list"),
        BlockedApp(bundleId: "com.netflix.Netflix", name: "Netflix", icon: "play.tv.fill"),
        BlockedApp(bundleId: "com.google.Maps", name: "Google Maps", icon: "map.fill"),
        BlockedApp(bundleId: "com.linkedin.LinkedIn", name: "LinkedIn", icon: "briefcase.fill"),
        BlockedApp(bundleId: "com.pinterest", name: "Pinterest", icon: "pin.fill"),
        BlockedApp(bundleId: "com.apple.mobilesafari", name: "Safari", icon: "safari.fill"),
        BlockedApp(bundleId: "com.apple.mobilemail", name: "Mail", icon: "envelope.fill"),
        BlockedApp(bundleId: "com.discord", name: "Discord", icon: "bubble.left.and.bubble.right.fill"),
        BlockedApp(bundleId: "com.tinder.Tinder", name: "Tinder", icon: "flame.fill")
    ]
}

