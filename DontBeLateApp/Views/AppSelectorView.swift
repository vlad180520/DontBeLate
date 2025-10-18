//
//  AppSelectorView.swift
//  DontBeLate
//
//  Created on 2025
//

import SwiftUI
import FamilyControls

struct AppSelectorView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var userSettings = UserSettings.shared
    @StateObject private var appBlockingService = AppBlockingService.shared
    @State private var selection = FamilyActivitySelection()
    @State private var isCheckingAuthorization = true
    @State private var isRequestingAuthorization = false
    @State private var authorizationError: String?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if isCheckingAuthorization {
                    // Checking authorization status
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Checking Screen Time Permission...")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if !appBlockingService.isAuthorized {
                    // Not authorized - show request button
                    ScrollView {
                        VStack(spacing: 24) {
                            Image(systemName: "hand.raised.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.orange)
                                .padding(.top, 40)
                            
                            Text("Screen Time Permission Required")
                                .font(.title2)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            
                            Text("To detect and block apps on your device, we need Screen Time permission.")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                PermissionInfoRow(
                                    icon: "apps.iphone",
                                    text: "Detect all installed apps"
                                )
                                PermissionInfoRow(
                                    icon: "hand.raised.fill",
                                    text: "Block selected apps before events"
                                )
                                PermissionInfoRow(
                                    icon: "lock.shield.fill",
                                    text: "Enforce app blocking with Screen Time"
                                )
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
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
                                .background(
                                    LinearGradient(
                                        colors: [Color.blue, Color.purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .disabled(isRequestingAuthorization)
                            .padding(.horizontal)
                            .padding(.top, 20)
                            
                            Spacer()
                        }
                    }
                } else {
                    // Authorized - show app picker
                    VStack(spacing: 0) {
                        // Info Header
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "app.badge.checkmark.fill")
                                    .font(.title)
                                    .foregroundColor(.blue)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Select Apps to Block")
                                        .font(.headline)
                                    Text("Choose from your installed apps")
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
                        
                        // Native iOS App Picker - Shows ALL installed apps
                        FamilyActivityPicker(selection: $selection)
                            .onChange(of: selection) { newSelection in
                                // Save the selected apps
                                userSettings.selectedAppsTokens = newSelection.applicationTokens
                                print("✅ Selected \(newSelection.applicationTokens.count) apps to block")
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let authorized = appBlockingService.checkAuthorization()
            isCheckingAuthorization = false
            
            if authorized {
                // Load previously selected apps
                var loadedSelection = FamilyActivitySelection()
                loadedSelection.applicationTokens = userSettings.selectedAppsTokens
                selection = loadedSelection
                print("✅ Screen Time authorized - showing app picker")
            } else {
                print("⚠️ Screen Time not authorized - showing permission request")
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
                    // Load previously selected apps
                    var loadedSelection = FamilyActivitySelection()
                    loadedSelection.applicationTokens = userSettings.selectedAppsTokens
                    selection = loadedSelection
                    print("✅ Authorization granted! Showing app picker")
                }
            } catch {
                await MainActor.run {
                    isRequestingAuthorization = false
                    authorizationError = "Permission denied. Please enable Screen Time in Settings."
                    print("❌ Authorization failed: \(error.localizedDescription)")
                }
            }
        }
    }
}

struct PermissionInfoRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            Text(text)
                .font(.subheadline)
            
            Spacer()
        }
    }
}

#Preview {
    AppSelectorView()
}

