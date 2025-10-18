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
                        // Traffic-based timing toggle (per event) - ALWAYS SHOW IF LOCATION EXISTS
                        if event.hasLocation {
                            VStack(alignment: .leading, spacing: 12) {
                                // Prominent header
                                HStack {
                                    Image(systemName: "car.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.title2)
                                    Text("Traffic-Based Timing")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                }
                                .padding(.bottom, 4)
                                
                                // Toggle with explanation
                                Toggle(isOn: $configuration.useTrafficTiming) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Use Smart Traffic Calculation")
                                            .fontWeight(.semibold)
                                        Text("Block apps based on real-time travel time + 5 min buffer")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .toggleStyle(SwitchToggleStyle(tint: .green))
                                .onChange(of: configuration.useTrafficTiming) { newValue in
                                    if !newValue {
                                        // Reset to manual timing
                                        configuration.minutesBeforeEvent = 15
                                    }
                                }
                                
                                if configuration.useTrafficTiming {
                                    HStack(spacing: 8) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Active")
                                                .fontWeight(.semibold)
                                                .foregroundColor(.green)
                                            Text("Calculates from your current location to event destination")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding(12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.green.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.green.opacity(0.05))
                            .cornerRadius(10)
                        } else {
                            // Show why traffic timing is not available
                            HStack {
                                Image(systemName: "location.slash")
                                    .foregroundColor(.orange)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Traffic Timing Unavailable")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.orange)
                                    Text("Add a location to this event to use traffic-based timing")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(10)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(8)
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
                                let appCount = UserSettings.shared.selectedAppsTokens.count
                                if appCount > 0 {
                                    HStack(spacing: 4) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                            .font(.caption)
                                        Text("\(appCount)")
                                            .foregroundColor(.green)
                                            .fontWeight(.semibold)
                                    }
                                } else {
                                    Text("None")
                                        .foregroundColor(.secondary)
                                }
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                        }
                        .foregroundColor(.primary)
                        
                        // Show selected apps - LIST FORMAT WITH NAMES
                        let selectedAppCount = UserSettings.shared.selectedAppsTokens.count
                        if selectedAppCount > 0 {
                            VStack(alignment: .leading, spacing: 10) {
                                // Header
                                HStack {
                                    Image(systemName: "lock.shield.fill")
                                        .foregroundColor(.red)
                                        .font(.title3)
                                    Text("Blocked Apps:")
                                        .font(.headline)
                                        .foregroundColor(.red)
                                }
                                
                                // List of apps
                                VStack(alignment: .leading, spacing: 8) {
                                    ForEach(0..<selectedAppCount, id: \.self) { index in
                                        HStack(spacing: 10) {
                                            // Bullet point
                                            Circle()
                                                .fill(Color.red)
                                                .frame(width: 6, height: 6)
                                            
                                            // App name
                                            Text("Selected App \(index + 1)")
                                                .font(.body)
                                                .foregroundColor(.primary)
                                            
                                            Spacer()
                                            
                                            // Lock icon
                                            Image(systemName: "lock.fill")
                                                .foregroundColor(.red)
                                                .font(.caption)
                                        }
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .background(Color.red.opacity(0.05))
                                        .cornerRadius(8)
                                    }
                                }
                                
                                // Info banner
                                HStack(spacing: 8) {
                                    Image(systemName: "info.circle.fill")
                                        .foregroundColor(.blue)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Specific Apps Only")
                                            .fontWeight(.semibold)
                                            .foregroundColor(.blue)
                                        Text("Only these \(selectedAppCount) app\(selectedAppCount == 1 ? "" : "s") will be blocked - not entire categories")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 12)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        } else {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.orange)
                                        .font(.title3)
                                    Text("No Apps Selected")
                                        .font(.headline)
                                        .foregroundColor(.orange)
                                }
                                
                                Text("Tap 'Select Apps to Block' above to choose which apps to block for this event")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                }
                
                // Summary
                if configuration.isEnabled {
                    Section(header: Text("Summary")) {
                        VStack(alignment: .leading, spacing: 12) {
                            // Timing summary
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: configuration.useTrafficTiming ? "car.circle.fill" : "clock.fill")
                                    .foregroundColor(configuration.useTrafficTiming ? .green : .blue)
                                    .font(.title3)
                                VStack(alignment: .leading, spacing: 4) {
                                    if configuration.useTrafficTiming {
                                        Text("Smart Traffic-Based Blocking")
                                            .fontWeight(.semibold)
                                        Text("Apps blocked based on real-time travel time + 5 min buffer")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    } else {
                                        Text("Manual Time Blocking")
                                            .fontWeight(.semibold)
                                        Text("Apps blocked \(configuration.minutesBeforeEvent) minutes before event")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            
                            Divider()
                            
                            // Apps summary
                            let appCount = UserSettings.shared.selectedAppsTokens.count
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: appCount > 0 ? "checkmark.shield.fill" : "exclamationmark.shield.fill")
                                    .foregroundColor(appCount > 0 ? .green : .orange)
                                    .font(.title3)
                                VStack(alignment: .leading, spacing: 4) {
                                    if appCount > 0 {
                                        Text("\(appCount) App\(appCount == 1 ? "" : "s") Selected")
                                            .fontWeight(.semibold)
                                        Text("Only these specific apps will be blocked")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    } else {
                                        Text("No Apps Selected")
                                            .fontWeight(.semibold)
                                            .foregroundColor(.orange)
                                        Text("Select apps to enable blocking")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            
                            // Blocking period
                            if appCount > 0 {
                                Divider()
                                
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "hourglass")
                                        .foregroundColor(.purple)
                                        .font(.title3)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Blocking Period")
                                            .fontWeight(.semibold)
                                        Text("From reminder time until event starts")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
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

