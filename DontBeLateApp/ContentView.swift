//
//  ContentView.swift
//  DontBeLate
//
//  Created on 2025
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if isLoading {
                LoadingView()
            } else if !appState.hasCompletedOnboarding {
                OnboardingView()
            } else {
                MainTabView()
            }
        }
        .onAppear {
            // Simulate initialization and check permissions
            Task {
                await appState.initializeApp()
                // Small delay to show loading animation
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                withAnimation {
                    isLoading = false
                }
            }
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            UpcomingEventsView()
                .tabItem {
                    Label("Events", systemImage: "calendar")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}

