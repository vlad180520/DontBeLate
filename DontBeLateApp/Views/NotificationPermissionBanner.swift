//
//  NotificationPermissionBanner.swift
//  DontBeLate
//
//  Created on 2025
//

import SwiftUI

struct NotificationPermissionBanner: View {
    @EnvironmentObject var appState: AppState
    @State private var isExpanded = true
    @State private var isRequesting = false
    
    var body: some View {
        if !appState.isNotificationAuthorized && isExpanded {
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Image(systemName: "bell.badge.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Enable Notifications")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Get reminders before your events")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            isExpanded = false
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(8)
                            .background(Color.secondary.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                .padding()
                
                HStack(spacing: 12) {
                    Button(action: {
                        requestNotificationPermission()
                    }) {
                        HStack {
                            if isRequesting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "bell.fill")
                                Text("Enable")
                            }
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                colors: [Color.orange, Color.red],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(10)
                    }
                    .disabled(isRequesting)
                    
                    Button(action: {
                        withAnimation {
                            isExpanded = false
                        }
                    }) {
                        Text("Later")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .background(Color(.systemBackground))
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            .padding(.horizontal)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
    
    private func requestNotificationPermission() {
        isRequesting = true
        
        appState.notificationService.requestAuthorization { granted, error in
            DispatchQueue.main.async {
                isRequesting = false
                
                if granted {
                    appState.isNotificationAuthorized = true
                    print("✅ Notification permission granted")
                    
                    // Show success feedback
                    withAnimation {
                        isExpanded = false
                    }
                } else {
                    print("❌ Notification permission denied")
                    // Show alert to go to Settings
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                    }
                    
                    // If user denied, offer to open Settings
                    showSettingsAlert()
                }
            }
        }
    }
    
    private func showSettingsAlert() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if UIApplication.shared.canOpenURL(url) {
                // In a real app, you'd show an alert here
                // For now, just log it
                print("💡 User should go to Settings to enable notifications")
            }
        }
    }
}

#Preview {
    NotificationPermissionBanner()
        .environmentObject(AppState())
}

