//
//  EventMonitor.swift
//  DontBeLate
//
//  Created on 2025
//

import Foundation
import Combine
import CoreLocation

class EventMonitor: ObservableObject {
    static let shared = EventMonitor()
    
    @Published var upcomingEvents: [EventModel] = []
    @Published var activeBlockRules: [AppBlockRule] = []
    
    private let calendarService = CalendarService.shared
    private let locationService = LocationService.shared
    private let notificationService = NotificationService.shared
    private let appBlockingService = AppBlockingService.shared
    private let userSettings = UserSettings.shared
    private let configManager = EventConfigurationManager.shared
    private let backendSync = BackendSyncService.shared
    
    private var monitoringTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        // Subscribe to calendar changes for live sync
        calendarService.calendarDidChange
            .sink { [weak self] in
                print("🔄 Live sync: Calendar changed, refreshing events...")
                self?.checkUpcomingEvents()
                
                // Sync to backend
                Task {
                    await self?.syncEventsToBackend()
                }
            }
            .store(in: &cancellables)
    }
    
    // Start monitoring calendar events
    func startMonitoring() {
        print("Starting event monitoring...")
        
        // Monitor every 5 minutes
        monitoringTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            self?.checkUpcomingEvents()
        }
        
        // Also check immediately
        checkUpcomingEvents()
    }
    
    // Stop monitoring
    func stopMonitoring() {
        print("Stopping event monitoring...")
        monitoringTimer?.invalidate()
        monitoringTimer = nil
    }
    
    // Check upcoming events and apply blocking rules
    func checkUpcomingEvents() {
        guard userSettings.autoBlockEnabled else { return }
        
        calendarService.fetchUpcomingEvents(daysAhead: 1) { [weak self] events in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.upcomingEvents = events
                self.processEvents(events)
                
                // Sync to backend
                Task {
                    await self.syncEventsToBackend()
                }
            }
        }
    }
    
    // Sync events to backend
    private func syncEventsToBackend() async {
        calendarService.fetchUpcomingEvents(daysAhead: 7) { [weak self] eventModels in
            guard let self = self else { return }
            
            // Convert EventModels to EKEvents for backend sync
            let ekEvents = eventModels.compactMap { model in
                self.calendarService.getEKEvent(by: model.id)
            }
            
            Task {
                await self.backendSync.performFullSync(with: ekEvents)
            }
        }
    }
    
    // Process events and create blocking rules
    private func processEvents(_ events: [EventModel]) {
        for event in events {
            // Skip past events
            guard event.startDate > Date() else { continue }
            
            // Check if we already have a rule for this event
            if activeBlockRules.contains(where: { $0.eventId == event.id }) {
                continue
            }
            
            // Check if event has custom configuration
            if let config = configManager.getConfiguration(for: event.id) {
                // Use per-event configuration
                if config.isEnabled {
                    processEventWithConfig(event, config: config)
                }
            } else if userSettings.autoBlockEnabled && !userSettings.blockedAppBundleIds.isEmpty {
                // Use global settings (only manual timing, traffic is per-event now)
                processEventWithDefaultTime(event)
            }
        }
        
        // Clean up expired rules
        activeBlockRules.removeAll { $0.blockEndTime < Date() }
    }
    
    // Process event with custom configuration
    private func processEventWithConfig(_ event: EventModel, config: EventConfiguration) {
        let blockedApps = config.blockedAppBundleIds
        
        guard !blockedApps.isEmpty else { return }
        
        // Check if this event should use traffic-based timing
        if config.useTrafficTiming && event.hasLocation {
            processEventWithTrafficAndConfig(event, config: config)
        } else {
            let minutesBefore = config.minutesBeforeEvent
            createBlockingRule(
                for: event,
                minutesBefore: minutesBefore,
                usesTraffic: false,
                travelTime: nil,
                customApps: blockedApps
            )
        }
    }
    
    // Process event with traffic and custom config (uses backend + local fallback)
    private func processEventWithTrafficAndConfig(_ event: EventModel, config: EventConfiguration) {
        guard let location = calendarService.getEventLocation(eventId: event.id) else {
            // Fallback to manual timing
            createBlockingRule(
                for: event,
                minutesBefore: config.minutesBeforeEvent,
                usesTraffic: false,
                travelTime: nil,
                customApps: config.blockedAppBundleIds
            )
            return
        }
        
        let destination = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        
        // Try backend calculation first
        Task {
            guard let userLocation = await locationService.getCurrentLocation() else {
                // Fallback to manual timing
                await MainActor.run {
                    self.createBlockingRule(
                        for: event,
                        minutesBefore: config.minutesBeforeEvent,
                        usesTraffic: false,
                        travelTime: nil,
                        customApps: config.blockedAppBundleIds
                    )
                }
                return
            }
            
            // 1. Try backend travel time calculation
            if let ekEvent = calendarService.getEKEvent(by: event.id) {
                let backendTravelMinutes = await backendSync.calculateTravelTime(
                    for: ekEvent,
                    from: (lat: userLocation.coordinate.latitude, lng: userLocation.coordinate.longitude)
                )
                
                if let travelMinutes = backendTravelMinutes {
                    // Backend calculation succeeded
                    let bufferMinutes = 5
                    let totalMinutes = travelMinutes + bufferMinutes
                    
                    await MainActor.run {
                        self.createBlockingRule(
                            for: event,
                            minutesBefore: totalMinutes,
                            usesTraffic: true,
                            travelTime: travelMinutes,
                            customApps: config.blockedAppBundleIds
                        )
                    }
                    return
                }
            }
            
            // 2. Fallback to local MapKit calculation
            locationService.calculateTravelTimeWithTraffic(to: destination) { [weak self] travelTime, error in
                guard let self = self else { return }
                
                if let travelTime = travelTime {
                    let travelMinutes = Int(ceil(travelTime / 60.0))
                    let bufferMinutes = 5
                    let totalMinutes = travelMinutes + bufferMinutes
                    
                    self.createBlockingRule(
                        for: event,
                        minutesBefore: totalMinutes,
                        usesTraffic: true,
                        travelTime: travelMinutes,
                        customApps: config.blockedAppBundleIds
                    )
                } else {
                    // Fallback to manual timing
                    self.createBlockingRule(
                        for: event,
                        minutesBefore: config.minutesBeforeEvent,
                        usesTraffic: false,
                        travelTime: nil,
                        customApps: config.blockedAppBundleIds
                    )
                }
            }
        }
    }
    
    // Process event with traffic calculation
    private func processEventWithTraffic(_ event: EventModel) {
        guard let location = calendarService.getEventLocation(eventId: event.id) else {
            // Fallback to default time if location not available
            processEventWithDefaultTime(event)
            return
        }
        
        let destination = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        
        locationService.calculateTravelTimeWithTraffic(to: destination) { [weak self] travelTime, error in
            guard let self = self, let travelTime = travelTime else {
                // Fallback to default time if calculation fails
                self?.processEventWithDefaultTime(event)
                return
            }
            
            let travelMinutes = Int(ceil(travelTime / 60.0))
            let bufferMinutes = 5 // Extra preparation time
            let totalMinutes = travelMinutes + bufferMinutes
            
            self.createBlockingRule(for: event, minutesBefore: totalMinutes, usesTraffic: true, travelTime: travelMinutes)
        }
    }
    
    // Process event with default time
    private func processEventWithDefaultTime(_ event: EventModel) {
        let minutesBefore = userSettings.defaultPreEventMinutes
        createBlockingRule(for: event, minutesBefore: minutesBefore, usesTraffic: false, travelTime: nil)
    }
    
    // Create blocking rule
    private func createBlockingRule(for event: EventModel, minutesBefore: Int, usesTraffic: Bool, travelTime: Int?, customApps: [String]? = nil) {
        guard let blockStartDate = Calendar.current.date(byAdding: .minute, value: -minutesBefore, to: event.startDate) else {
            return
        }
        
        // Don't create rules for events that should already be blocked
        guard blockStartDate > Date() else { return }
        
        let appsToBlock = customApps ?? userSettings.blockedAppBundleIds
        
        let rule = AppBlockRule(
            eventId: event.id,
            blockedAppBundleIds: appsToBlock,
            blockStartTime: blockStartDate,
            blockEndTime: event.startDate,
            usesTrafficCalculation: usesTraffic
        )
        
        var updatedRule = rule
        updatedRule.travelTimeMinutes = travelTime
        
        activeBlockRules.append(updatedRule)
        
        // Schedule notifications
        if userSettings.enableNotifications {
            // Schedule event reminder (general reminder)
            notificationService.scheduleEventReminder(
                eventTitle: event.title,
                eventStartDate: event.startDate,
                minutesBefore: minutesBefore
            ) { success in
                if success {
                    print("📅 Event reminder scheduled for: \(event.title)")
                }
            }
            
            // Schedule app blocking notification
            if usesTraffic, let travelMinutes = travelTime {
                notificationService.scheduleTrafficBasedNotification(
                    eventTitle: event.title,
                    eventStartDate: event.startDate,
                    travelTimeMinutes: travelMinutes
                ) { success in
                    if success {
                        print("🚗 Traffic-based notification scheduled for: \(event.title)")
                    }
                }
            } else {
                notificationService.scheduleAppBlockNotification(
                    eventTitle: event.title,
                    eventStartDate: event.startDate,
                    minutesBefore: minutesBefore
                ) { success in
                    if success {
                        print("🔔 Blocking notification scheduled for: \(event.title)")
                    }
                }
            }
        }
        
        // Schedule app blocking
        scheduleAppBlocking(rule: updatedRule, event: event)
    }
    
    // Schedule app blocking
    private func scheduleAppBlocking(rule: AppBlockRule, event: EventModel) {
        let timeUntilBlock = rule.blockStartTime.timeIntervalSince(Date())
        
        guard timeUntilBlock > 0 else { return }
        
        // Schedule timer to activate blocking
        DispatchQueue.main.asyncAfter(deadline: .now() + timeUntilBlock) { [weak self] in
            self?.activateBlocking(for: rule, event: event)
        }
    }
    
    // Activate app blocking (ACTUAL BLOCKING with Screen Time API)
    private func activateBlocking(for rule: AppBlockRule, event: EventModel) {
        guard rule.blockStartTime <= Date() && rule.blockEndTime > Date() else { return }
        
        // ⚠️ CRITICAL: Use actual ApplicationToken objects for blocking
        let appTokens = userSettings.selectedAppsTokens
        
        if !appTokens.isEmpty {
            // Block apps using Screen Time API with actual tokens
            appBlockingService.blockApps(appTokens: appTokens, until: rule.blockEndTime)
            
            // Notify backend about blocking session
            Task {
                await backendSync.startBlockingSession(
                    eventId: event.id,
                    eventTitle: event.title,
                    blockedApps: rule.blockedAppBundleIds,
                    startTime: rule.blockStartTime,
                    endTime: rule.blockEndTime
                )
            }
            
            print("🔒 ACTUAL BLOCKING ACTIVE for event: \(event.title)")
            print("   📱 Blocked apps: \(appTokens.count)")
            print("   ⏰ Until: \(rule.blockEndTime)")
        } else {
            print("⚠️ No app tokens selected - cannot block apps")
        }
        
        // Update rule status
        if let index = activeBlockRules.firstIndex(where: { $0.id == rule.id }) {
            activeBlockRules[index].isActive = true
        }
        
        // Send detailed notification with app names
        sendBlockingNotification(for: event, appCount: appTokens.count, blockedApps: rule.blockedAppBundleIds)
        
        // Schedule unblocking at event start time
        let timeUntilUnblock = rule.blockEndTime.timeIntervalSince(Date())
        DispatchQueue.main.asyncAfter(deadline: .now() + timeUntilUnblock) { [weak self] in
            self?.deactivateBlocking(for: rule, event: event)
        }
    }
    
    // Send notification when apps are blocked
    private func sendBlockingNotification(for event: EventModel, appCount: Int, blockedApps: [String]) {
        let appNames = getAppNames(from: blockedApps)
        let appsList = appNames.prefix(3).joined(separator: ", ")
        let remaining = appCount > 3 ? " and \(appCount - 3) more" : ""
        
        let title = "🔒 \(appCount) App\(appCount == 1 ? "" : "s") Blocked!"
        let body = """
        Event: \(event.title)
        Blocked: \(appsList)\(remaining)
        Stay focused until your event!
        """
        
        notificationService.sendImmediateNotification(title: title, body: body)
    }
    
    // Get readable app names from bundle IDs
    private func getAppNames(from bundleIds: [String]) -> [String] {
        let allApps = AppBlockingService.commonApps
        return bundleIds.compactMap { bundleId in
            allApps.first(where: { $0.bundleId == bundleId })?.name
        }
    }
    
    // Deactivate app blocking (when event starts)
    private func deactivateBlocking(for rule: AppBlockRule, event: EventModel) {
        // Unblock apps using Screen Time API
        appBlockingService.unblockApps()
        
        // Notify backend
        Task {
            await backendSync.endBlockingSession(eventId: event.id)
        }
        
        // Remove rule
        activeBlockRules.removeAll { $0.id == rule.id }
        
        print("✅ Apps unblocked - event started: \(event.title)")
        
        // Send unblocking notification
        notificationService.sendImmediateNotification(
            title: "✅ Apps Unblocked",
            body: "Event '\(event.title)' has started. Your apps are now available!"
        )
    }
    
    // Manual refresh
    func refreshEvents() {
        checkUpcomingEvents()
    }
}

