//
//  ActiveBlocksView.swift
//  DontBeLate
//
//  Created on 2025
//

import SwiftUI

struct ActiveBlocksView: View {
    @StateObject private var eventMonitor = EventMonitor.shared
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                if eventMonitor.activeBlockRules.filter({ $0.isActive }).isEmpty {
                    Section {
                        VStack(spacing: 20) {
                            Image(systemName: "lock.open.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.green)
                            
                            Text("No Active Blocks")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Text("You don't have any apps blocked right now")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    }
                } else {
                    ForEach(eventMonitor.activeBlockRules.filter({ $0.isActive }), id: \.id) { rule in
                        Section(header: Text("Event: \(getEventName(for: rule.eventId))")) {
                            HStack {
                                Image(systemName: "clock.fill")
                                    .foregroundColor(.blue)
                                Text("Blocked Until")
                                Spacer()
                                Text(rule.blockEndTime, style: .time)
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack {
                                Image(systemName: "app.badge")
                                    .foregroundColor(.red)
                                Text("Apps Blocked")
                                Spacer()
                                Text("\(rule.blockedAppBundleIds.count)")
                                    .foregroundColor(.secondary)
                            }
                            
                            ForEach(getAppNames(from: rule.blockedAppBundleIds), id: \.self) { appName in
                                HStack {
                                    Image(systemName: "lock.fill")
                                        .foregroundColor(.orange)
                                        .font(.caption)
                                    Text(appName)
                                        .font(.subheadline)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Active Blocks")
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
    
    private func getEventName(for eventId: String) -> String {
        if let event = CalendarService.shared.getEvent(by: eventId) {
            return event.title
        }
        return "Unknown Event"
    }
    
    private func getAppNames(from bundleIds: [String]) -> [String] {
        let allApps = AppBlockingService.commonApps
        return bundleIds.compactMap { bundleId in
            allApps.first(where: { $0.bundleId == bundleId })?.name
        }
    }
}

#Preview {
    ActiveBlocksView()
}

