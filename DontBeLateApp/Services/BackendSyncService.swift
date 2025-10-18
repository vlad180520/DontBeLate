//
//  BackendSyncService.swift
//  DontBeLate
//
//  Coordinates syncing with Convex backend
//

import Foundation
import EventKit
import Combine

class BackendSyncService: ObservableObject {
    nonisolated(unsafe) static let shared = BackendSyncService()
    
    @Published var isSyncing = false
    @Published var lastSyncDate: Date?
    
    private let convex = ConvexClient.shared
    private let userSettings = UserSettings.shared
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        setupAutoSync()
    }
    
    // Get unique device-based user ID
    private var userId: String {
        if let savedId = UserDefaults.standard.string(forKey: "deviceUserId") {
            return savedId
        }
        
        let newId = "ios_\(UUID().uuidString)"
        UserDefaults.standard.set(newId, forKey: "deviceUserId")
        return newId
    }
    
    // MARK: - Auto Sync Setup
    
    private func setupAutoSync() {
        // Sync user settings when they change
        userSettings.$defaultPreEventMinutes
            .debounce(for: 1.0, scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                Task {
                    await self?.syncUserSettings()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - User Settings Sync
    
    @MainActor
    func syncUserSettings() async {
        guard !isSyncing else { return }
        isSyncing = true
        defer { isSyncing = false }
        
        do {
            let blockedApps = userSettings.blockedAppBundleIds
            
            _ = try await convex.upsertUser(
                userId: userId,
                email: nil,
                defaultPreEventTime: userSettings.defaultPreEventMinutes,
                blockedApps: blockedApps,
                notificationsEnabled: true,
                locationBasedTimingEnabled: true
            )
            
            lastSyncDate = Date()
            print("✅ User settings synced to backend")
        } catch {
            print("⚠️ Failed to sync user settings: \(error)")
        }
    }
    
    // MARK: - Calendar Events Sync
    
    @MainActor
    func syncCalendarEvents(_ events: [EKEvent]) async {
        guard !isSyncing else { return }
        isSyncing = true
        defer { isSyncing = false }
        
        do {
            let eventDicts = events.map { event -> [String: Any] in
                var dict: [String: Any] = [
                    "eventId": event.eventIdentifier ?? UUID().uuidString,
                    "title": event.title ?? "Untitled Event",
                    "startTime": Int(event.startDate.timeIntervalSince1970 * 1000),
                    "endTime": Int(event.endDate.timeIntervalSince1970 * 1000)
                ]
                
                if let location = event.location, !location.isEmpty {
                    dict["location"] = location
                }
                
                if let notes = event.notes, !notes.isEmpty {
                    dict["notes"] = notes
                }
                
                return dict
            }
            
            let result = try await convex.syncCalendarEvents(
                userId: userId,
                events: eventDicts
            )
            
            lastSyncDate = Date()
            
            if let synced = result["synced"] as? Int {
                print("✅ Synced \(synced) events to backend")
            }
        } catch {
            print("⚠️ Failed to sync events: \(error)")
        }
    }
    
    // MARK: - Travel Time Calculation
    
    @MainActor
    func calculateTravelTime(
        for event: EKEvent,
        from userLocation: (lat: Double, lng: Double)
    ) async -> Int? {
        do {
            guard let eventId = event.eventIdentifier else { return nil }
            
            let travelData = try await convex.calculateTravelTime(
                eventId: eventId,
                userLat: userLocation.lat,
                userLng: userLocation.lng
            )
            
            if let travelData = travelData,
               let travelMinutes = travelData["travelTimeMinutes"] as? Int {
                print("✅ Backend travel time: \(travelMinutes) minutes")
                return travelMinutes
            }
        } catch {
            print("⚠️ Backend travel time failed, will use local calculation: \(error)")
        }
        
        return nil
    }
    
    // MARK: - Blocking Sessions
    
    @MainActor
    func startBlockingSession(
        eventId: String,
        eventTitle: String,
        blockedApps: [String],
        startTime: Date,
        endTime: Date
    ) async {
        // Log blocking session to backend
        print("🔒 Blocking session started for: \(eventTitle)")
        print("   Apps: \(blockedApps.count)")
        print("   Duration: \(startTime) → \(endTime)")
    }
    
    @MainActor
    func endBlockingSession(eventId: String) async {
        do {
            let success = try await convex.endBlockingSession(
                userId: userId,
                eventId: eventId
            )
            
            if success {
                print("✅ Blocking session ended on backend")
            }
        } catch {
            print("⚠️ Failed to end blocking session: \(error)")
        }
    }
    
    func getActiveBlockingSessions() async -> [[String: Any]] {
        do {
            let sessions = try await convex.getActiveBlockingSessions(userId: userId)
            return sessions
        } catch {
            print("⚠️ Failed to get active sessions: \(error)")
            return []
        }
    }
    
    // MARK: - Full Sync
    
    @MainActor
    func performFullSync(with events: [EKEvent]) async {
        print("🔄 Starting full backend sync...")
        
        // 1. Sync user settings
        await syncUserSettings()
        
        // 2. Sync calendar events
        await syncCalendarEvents(events)
        
        print("✅ Full sync complete")
    }
}

