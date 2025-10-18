//
//  AppBlockingInfoView.swift
//  DontBeLate
//
//  Created on 2025
//

import SwiftUI

struct AppBlockingInfoView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(spacing: 10) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("About App Blocking")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top)
                    
                    // How it works
                    InfoSection(
                        icon: "checkmark.circle.fill",
                        color: .green,
                        title: "What This App Does",
                        points: [
                            "Sends reminders before your events",
                            "Tracks apps you want to avoid",
                            "Calculates travel time with traffic",
                            "Helps you stay focused and on time"
                        ]
                    )
                    
                    // Limitations
                    InfoSection(
                        icon: "exclamationmark.triangle.fill",
                        color: .orange,
                        title: "iOS Limitations",
                        points: [
                            "App blocking requires Screen Time API",
                            "Only works on real iPhones (not Simulator)",
                            "Requires Screen Time to be enabled in Settings",
                            "System apps (Phone, Messages) cannot be blocked",
                            "Needs special approval from Apple for full functionality"
                        ]
                    )
                    
                    // How to enable
                    InfoSection(
                        icon: "gear",
                        color: .blue,
                        title: "Enable Screen Time",
                        points: [
                            "Open Settings → Screen Time",
                            "Turn on Screen Time if it's off",
                            "Grant permissions when prompted by this app",
                            "Note: Full blocking may require additional device setup"
                        ]
                    )
                    
                    // Workaround
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.yellow)
                            Text("Pro Tip")
                                .font(.headline)
                        }
                        
                        Text("Even without full app blocking, notifications and awareness of upcoming events can help you stay on track. The app will remind you to put your phone down and prepare for your commitments!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 2)
                }
                .padding()
            }
            .navigationTitle("App Blocking Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct InfoSection: View {
    let icon: String
    let color: Color
    let title: String
    let points: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.headline)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(points, id: \.self) { point in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .foregroundColor(color)
                        Text(point)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

#Preview {
    AppBlockingInfoView()
}

