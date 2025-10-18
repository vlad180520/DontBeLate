//
//  EventDetailView.swift
//  DontBeLate
//
//  Created on 2025
//

import SwiftUI
import EventKit
import FamilyControls

struct EventDetailView: View {
    let event: EventModel
    @StateObject private var configManager = EventConfigurationManager.shared
    @State private var configuration: EventConfiguration
    @State private var showingAppSelector = false
    @Environment(\.dismiss) var dismiss
    
    init(event: EventModel) {
        self.event = event
        
        // Initialize configuration
        if let existing = EventConfigurationManager.shared.getConfiguration(for: event.id) {
            _configuration = State(initialValue: existing)
        } else {
            let newConfig = EventConfiguration(
                eventId: event.id,
                eventTitle: event.title,
                blockedAppBundleIds: UserSettings.shared.blockedAppBundleIds,
                minutesBeforeEvent: UserSettings.shared.defaultPreEventMinutes
            )
            _configuration = State(initialValue: newConfig)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Event Info Section
                Section(header: Text("Event Details")) {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                        Text("Title")
                        Spacer()
                        Text(event.title)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.blue)
                        Text("Start Time")
                        Spacer()
                        Text(event.startDate, style: .time)
                            .foregroundColor(.secondary)
                    }
                    
                    if let location = event.location {
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundColor(.blue)
                            Text("Location")
                            Spacer()
                            Text(location)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
                
                // App Blocking Configuration
                Section(header: Text("App Blocking")) {
                    Toggle("Enable App Blocking", isOn: $configuration.isEnabled)
                    
                    if configuration.isEnabled {
                        // Traffic-based timing toggle (per event) - PROMINENTLY DISPLAYED
                        if event.hasLocation {
                            VStack(spacing: 12) {
                                Toggle(isOn: $configuration.useTrafficTiming) {
                                    HStack {
                                        Image(systemName: "car.circle.fill")
                                            .foregroundColor(.green)
                                            .font(.title3)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Smart Traffic Timing")
                                                .fontWeight(.semibold)
                                            Text("Auto-calculate based on live traffic")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                .onChange(of: configuration.useTrafficTiming) { newValue in
                                    if !newValue {
                                        // Reset to manual timing
                                        configuration.minutesBeforeEvent = 15
                                    }
                                }
                                .padding(.vertical, 4)
                                
                                if configuration.useTrafficTiming {
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                        Text("Apps will be blocked based on real-time travel time from your location to the event destination")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(10)
                                    .background(Color.green.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                        }
                        
                        if !configuration.useTrafficTiming {
                            Picker("Block Apps Before Event", selection: $configuration.minutesBeforeEvent) {
                                Text("5 min").tag(5)
                                Text("10 min").tag(10)
                                Text("15 min").tag(15)
                                Text("30 min").tag(30)
                                Text("45 min").tag(45)
                                Text("60 min").tag(60)
                            }
                        }
                        
                        Button(action: {
                            showingAppSelector = true
                        }) {
                            HStack {
                                Image(systemName: "apps.iphone")
                                    .foregroundColor(.purple)
                                Text("Select Apps to Block")
                                Spacer()
                                Text("\(configuration.blockedAppBundleIds.count)")
                                    .foregroundColor(.secondary)
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .foregroundColor(.primary)
                        
                        // Show selected apps
                        if !configuration.blockedAppBundleIds.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Blocked Apps:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                ForEach(getBlockedApps(), id: \.bundleId) { app in
                                    HStack {
                                        Image(systemName: app.icon)
                                            .foregroundColor(.red)
                                        Text(app.name)
                                            .font(.subheadline)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                
                // Summary
                if configuration.isEnabled {
                    Section(header: Text("Summary")) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Your selected apps will be blocked \(configuration.minutesBeforeEvent) minutes before this event.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            if !configuration.blockedAppBundleIds.isEmpty {
                                Text("Apps to block: \(configuration.blockedAppBundleIds.count)")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            } else {
                                Text("⚠️ No apps selected to block")
                                    .font(.subheadline)
                                    .foregroundColor(.orange)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Event Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveConfiguration()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showingAppSelector) {
                EventAppSelectorView(selectedAppIds: $configuration.blockedAppBundleIds)
            }
        }
    }
    
    private func saveConfiguration() {
        configManager.saveConfiguration(configuration)
    }
    
    private func getBlockedApps() -> [BlockedApp] {
        let allApps = AppBlockingService.commonApps
        return allApps.filter { configuration.blockedAppBundleIds.contains($0.bundleId) }
    }
}

// App selector for per-event configuration  
struct EventAppSelectorView: View {
    @Binding var selectedAppIds: [String]
    @Environment(\.dismiss) var dismiss
    @StateObject private var appBlockingService = AppBlockingService.shared
    @State private var selection = FamilyActivitySelection()
    @State private var isCheckingAuthorization = true
    @State private var isRequestingAuthorization = false
    @State private var authorizationError: String?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if isCheckingAuthorization {
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Checking Screen Time Permission...")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if !appBlockingService.isAuthorized {
                    ScrollView {
                        VStack(spacing: 24) {
                            Image(systemName: "hand.raised.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.purple)
                                .padding(.top, 40)
                            
                            Text("Screen Time Permission Required")
                                .font(.title2)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            
                            Text("Grant Screen Time permission to select apps for this event.")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            if let error = authorizationError {
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .padding()
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(8)
                                    .padding(.horizontal)
                            }
                            
                            Button(action: {
                                requestAuthorization()
                            }) {
                                HStack {
                                    if isRequestingAuthorization {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Image(systemName: "checkmark.shield.fill")
                                        Text("Grant Permission")
                                            .fontWeight(.semibold)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.purple)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .disabled(isRequestingAuthorization)
                            .padding(.horizontal)
                            .padding(.top, 20)
                        }
                    }
                } else {
                    // Authorized - show app picker
                    VStack(spacing: 0) {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "app.badge.checkmark.fill")
                                    .font(.title)
                                    .foregroundColor(.purple)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Block Apps for This Event")
                                        .font(.headline)
                                    Text("Select from your installed apps")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            if !selection.applicationTokens.isEmpty {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text("\(selection.applicationTokens.count) app(s) selected")
                                        .font(.subheadline)
                                        .foregroundColor(.green)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        
                        FamilyActivityPicker(selection: $selection)
                            .onChange(of: selection) { newSelection in
                                UserSettings.shared.selectedAppsTokens = newSelection.applicationTokens
                                selectedAppIds = Array(repeating: "token", count: newSelection.applicationTokens.count)
                                print("✅ Selected \(newSelection.applicationTokens.count) apps for event")
                            }
                    }
                }
            }
            .navigationTitle("Block Apps")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                checkAuthorizationStatus()
            }
        }
    }
    
    private func checkAuthorizationStatus() {
        isCheckingAuthorization = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let authorized = appBlockingService.checkAuthorization()
            isCheckingAuthorization = false
            
            if authorized {
                var loadedSelection = FamilyActivitySelection()
                loadedSelection.applicationTokens = UserSettings.shared.selectedAppsTokens
                selection = loadedSelection
            }
        }
    }
    
    private func requestAuthorization() {
        isRequestingAuthorization = true
        authorizationError = nil
        
        Task {
            do {
                try await appBlockingService.requestAuthorization()
                
                await MainActor.run {
                    isRequestingAuthorization = false
                    var loadedSelection = FamilyActivitySelection()
                    loadedSelection.applicationTokens = UserSettings.shared.selectedAppsTokens
                    selection = loadedSelection
                }
            } catch {
                await MainActor.run {
                    isRequestingAuthorization = false
                    authorizationError = "Permission denied."
                }
            }
        }
    }
}

#Preview {
    EventDetailView(event: EventModel(from: EKEvent()))
}

