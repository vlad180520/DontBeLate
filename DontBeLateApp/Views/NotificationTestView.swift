//
//  NotificationTestView.swift
//  DontBeLate
//
//  Created on 2025
//

import SwiftUI

struct NotificationTestView: View {
    @State private var testAppCount = 3
    @State private var testEventName = "Team Meeting"
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Test Blocking Notification")) {
                    TextField("Event Name", text: $testEventName)
                    
                    Stepper("Apps to Block: \(testAppCount)", value: $testAppCount, in: 1...10)
                    
                    Button("Send Test Notification") {
                        sendTestNotification()
                    }
                }
                
                Section(header: Text("Preview")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("🔒 \(testAppCount) App\(testAppCount == 1 ? "" : "s") Blocked!")
                            .font(.headline)
                        
                        Text("Event: \(testEventName)")
                            .font(.subheadline)
                        
                        Text("Blocked: Instagram, Facebook, Twitter")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Test Notifications")
        }
    }
    
    private func sendTestNotification() {
        let title = "🔒 \(testAppCount) App\(testAppCount == 1 ? "" : "s") Blocked!"
        let body = """
        Event: \(testEventName)
        Blocked: Instagram, Facebook, Twitter
        Stay focused until your event!
        """
        
        NotificationService.shared.sendImmediateNotification(
            title: title,
            body: body,
            badge: testAppCount
        )
    }
}

#Preview {
    NotificationTestView()
}

