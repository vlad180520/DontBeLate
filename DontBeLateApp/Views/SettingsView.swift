//
//  SettingsView.swift
//  DontBeLate
//
//  Created on 2025
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var userSettings = UserSettings.shared
    @StateObject private var appBlockingService = AppBlockingService.shared
    @State private var showingAppSelector = false
    @State private var showingAppBlockingInfo = false
    @State private var showingUnblockConfirmation = false
    @State private var showingUnblockSuccess = false
    
    var body: some View {
        NavigationView {
            Form {
                // General Settings
                Section(header: Text("General"), footer: Text("Configure individual events to use traffic-based timing. Tap any event to customize.")) {
                    HStack {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.blue)
                        Text("Default Buffer Time")
                        Spacer()
                        Picker("", selection: $userSettings.defaultPreEventMinutes) {
                            Text("5 min").tag(5)
                            Text("10 min").tag(10)
                            Text("15 min").tag(15)
                            Text("30 min").tag(30)
                            Text("45 min").tag(45)
                            Text("60 min").tag(60)
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    Toggle(isOn: $userSettings.autoBlockEnabled) {
                        HStack {
                            Image(systemName: "app.badge")
                                .foregroundColor(.red)
                            Text("Auto Block Apps")
                        }
                    }
                }
                
                // App Blocking
                Section(header: Text("Blocked Apps"), footer: Text("Note: App blocking requires Screen Time to be enabled and works best on real devices.")) {
                    Button(action: {
                        showingAppSelector = true
                    }) {
                        HStack {
                            Image(systemName: "apps.iphone")
                                .foregroundColor(.purple)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Select Apps to Block")
                                Text("From your installed apps")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text("\(userSettings.selectedAppsTokens.count)")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(userSettings.selectedAppsTokens.isEmpty ? .secondary : .green)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }
                    .foregroundColor(.primary)
                    
                    Button(action: {
                        showingAppBlockingInfo = true
                    }) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                            Text("About App Blocking")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }
                    .foregroundColor(.primary)
                }
                
                // Emergency Unblock
                Section(header: Text("Emergency Controls")) {
                    Button(action: {
                        showingUnblockConfirmation = true
                    }) {
                        HStack {
                            Image(systemName: "lock.open.fill")
                                .foregroundColor(.orange)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Unblock All Apps")
                                    .fontWeight(.semibold)
                                Text("Remove all active blocking shields")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                        }
                    }
                    .foregroundColor(.primary)
                }
                
                // Notifications
                Section(header: Text("Notifications"), footer: Text("Receive push notifications for event reminders, app blocking alerts, and traffic updates.")) {
                    Toggle(isOn: $userSettings.enableNotifications) {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(.orange)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Enable Notifications")
                                Text("Event reminders & alerts")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    NavigationLink(destination: NotificationTestView()) {
                        HStack {
                            Image(systemName: "bell.badge")
                                .foregroundColor(.orange)
                            Text("Test Notifications")
                        }
                    }
                    
                    NavigationLink(destination: ActiveBlocksView()) {
                        HStack {
                            Image(systemName: "lock.rectangle.stack")
                                .foregroundColor(.red)
                            Text("Active Blocks")
                        }
                    }
                }
                
                // About
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Link(destination: URL(string: "https://github.com")!) {
                        HStack {
                            Image(systemName: "link")
                                .foregroundColor(.blue)
                            Text("GitHub Repository")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingAppSelector) {
                AppSelectorView()
            }
            .sheet(isPresented: $showingAppBlockingInfo) {
                AppBlockingInfoView()
            }
            .alert("Unblock All Apps?", isPresented: $showingUnblockConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Unblock", role: .destructive) {
                    unblockAllApps()
                }
            } message: {
                Text("This will immediately remove all app blocking shields and make all apps accessible again.")
            }
            .alert("Apps Unblocked", isPresented: $showingUnblockSuccess) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("All apps are now accessible. Blocking will resume at the next scheduled event time.")
            }
        }
    }
    
    // Unblock all apps
    private func unblockAllApps() {
        appBlockingService.unblockApps()
        
        // Show success alert
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showingUnblockSuccess = true
        }
        
        print("✅ Manual unblock triggered from Settings")
    }
}

#Preview {
    SettingsView()
}

