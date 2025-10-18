//
//  OnboardingView.swift
//  DontBeLate
//
//  Created on 2025
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentPage = 0
    @State private var isRequestingPermissions = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack {
                TabView(selection: $currentPage) {
                    WelcomePage()
                        .tag(0)
                    
                    FeaturePage(
                        icon: "calendar.badge.clock",
                        title: "Smart Calendar Sync",
                        description: "Automatically syncs with your iOS calendar and monitors upcoming events"
                    )
                    .tag(1)
                    
                    FeaturePage(
                        icon: "app.badge",
                        title: "App Blocking",
                        description: "Block distracting apps before events to help you prepare and stay focused"
                    )
                    .tag(2)
                    
                    FeaturePage(
                        icon: "car.fill",
                        title: "Traffic-Based Timing",
                        description: "Dynamically calculates when to leave based on real-time traffic conditions"
                    )
                    .tag(3)
                    
                    PermissionsPage(isRequestingPermissions: $isRequestingPermissions)
                        .tag(4)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                
                if currentPage < 4 {
                    Button(action: {
                        withAnimation {
                            currentPage += 1
                        }
                    }) {
                        Text("Next")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 30)
                } else {
                    Button(action: {
                        requestPermissionsAndComplete()
                    }) {
                        if isRequestingPermissions {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Get Started")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(12)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 30)
                    .disabled(isRequestingPermissions)
                }
            }
        }
    }
    
    private func requestPermissionsAndComplete() {
        isRequestingPermissions = true
        
        // Request calendar permission
        appState.calendarService.requestAccess { granted, error in
            if granted {
                print("Calendar access granted")
            }
            
            // Request location permission
            appState.locationService.requestAuthorization()
            
            // Request notification permission
            appState.notificationService.requestAuthorization { granted, error in
                if granted {
                    print("Notification access granted")
                }
                
                // Request Screen Time permission (if available)
                Task {
                    do {
                        try await AppBlockingService.shared.requestAuthorization()
                        print("Screen Time access granted")
                    } catch {
                        print("Screen Time access denied: \(error.localizedDescription)")
                    }
                    
                    DispatchQueue.main.async {
                        isRequestingPermissions = false
                        appState.completeOnboarding()
                    }
                }
            }
        }
    }
}

struct WelcomePage: View {
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "clock.badge.checkmark.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .foregroundColor(.white)
            
            Text("Don't Be Late")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(.white)
            
            Text("Never miss an important event again")
                .font(.title3)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
}

struct FeaturePage: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text(description)
                .font(.title3)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
}

struct PermissionsPage: View {
    @Binding var isRequestingPermissions: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "lock.shield.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(.white)
            
            Text("Required Permissions")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 20) {
                PermissionRow(icon: "calendar", text: "Calendar - To read your events")
                PermissionRow(icon: "location.fill", text: "Location - To calculate travel time")
                PermissionRow(icon: "bell.fill", text: "Notifications - Event reminders & alerts")
                PermissionRow(icon: "app.badge", text: "Screen Time - To block distracting apps")
            }
            .padding(.horizontal, 40)
            
            Text("💡 You'll receive push notifications when:\n• Event is coming up\n• Apps are blocked\n• Time to leave based on traffic")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.top, 8)
            
            Spacer()
        }
    }
}

struct PermissionRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(.white)
                .frame(width: 30)
            
            Text(text)
                .foregroundColor(.white.opacity(0.9))
                .font(.body)
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppState())
}

