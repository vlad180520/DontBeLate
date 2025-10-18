//
//  HomeView.swift
//  DontBeLate
//
//  Created on 2025
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Notification Permission Banner
                    NotificationPermissionBanner()
                        .padding(.top, 8)
                    
                    // Status Card
                    StatusCard(
                        nextEvent: viewModel.nextEvent,
                        timeUntil: viewModel.timeUntilNextEvent(),
                        activeBlockingCount: viewModel.activeBlockingCount
                    )
                    .padding(.horizontal)
                    .padding(.top, appState.isNotificationAuthorized ? 0 : 8)
                    
                    // Today's Events
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Today's Events")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        if viewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else if viewModel.todayEvents.isEmpty {
                            EmptyStateView()
                                .padding()
                        } else {
                            ForEach(viewModel.todayEvents) { event in
                                NavigationLink(destination: EventDetailView(event: event)) {
                                    EventCard(event: event)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Don't Be Late")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.refreshEvents()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .onAppear {
                viewModel.loadTodayEvents()
            }
            .refreshable {
                viewModel.refreshEvents()
            }
        }
    }
}

struct StatusCard: View {
    let nextEvent: EventModel?
    let timeUntil: String?
    let activeBlockingCount: Int
    @State private var showingActiveBlocks = false
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: "clock.fill")
                    .font(.largeTitle)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Next Event")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    if let event = nextEvent {
                        Text(event.title)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .lineLimit(2)
                    } else {
                        Text("No upcoming events")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Time Until")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(timeUntil ?? "--")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Button(action: {
                    if activeBlockingCount > 0 {
                        showingActiveBlocks = true
                    }
                }) {
                    VStack(alignment: .trailing) {
                        Text("Apps Blocked")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        HStack(spacing: 4) {
                            Text("\(activeBlockingCount)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(activeBlockingCount > 0 ? .red : .green)
                            if activeBlockingCount > 0 {
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(activeBlockingCount == 0)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .sheet(isPresented: $showingActiveBlocks) {
            ActiveBlocksView()
        }
    }
}

struct EventCard: View {
    let event: EventModel
    @StateObject private var configManager = EventConfigurationManager.shared
    @StateObject private var eventMonitor = EventMonitor.shared
    
    private var isUpcoming: Bool {
        event.startDate > Date()
    }
    
    private var configuration: EventConfiguration? {
        configManager.getConfiguration(for: event.id)
    }
    
    // Check if this event has an ACTIVE blocking rule right now
    private var activeBlockRule: AppBlockRule? {
        eventMonitor.activeBlockRules.first { rule in
            rule.eventId == event.id && rule.isActive
        }
    }
    
    var body: some View {
        HStack(spacing: 15) {
            VStack {
                Text(event.startDate, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(width: 60)
            
            Rectangle()
                .fill(isUpcoming ? Color.blue : Color.gray.opacity(0.5))
                .frame(width: 4)
                .cornerRadius(2)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(event.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if let location = event.location {
                    HStack(spacing: 5) {
                        Image(systemName: "location.fill")
                            .font(.caption)
                        Text(location)
                            .font(.caption)
                            .lineLimit(1)
                    }
                    .foregroundColor(.secondary)
                }
                
                HStack(spacing: 5) {
                    Image(systemName: "calendar")
                        .font(.caption)
                    Text(event.calendar)
                        .font(.caption)
                }
                .foregroundColor(.secondary)
                
                // ONLY show blocked apps count when ACTIVELY blocked
                if let activeRule = activeBlockRule {
                    HStack(spacing: 5) {
                        Image(systemName: "lock.circle.fill")
                            .font(.caption)
                        Text("🔒 \(activeRule.blockedAppBundleIds.count) apps blocked")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.red)
                    .padding(.vertical, 2)
                    .padding(.horizontal, 6)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(4)
                }
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                // Show traffic icon if using traffic timing
                if let config = configuration, config.useTrafficTiming && event.hasLocation {
                    Image(systemName: "car.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                        .padding(4)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(4)
                }
                
                // Show lock icon if configured (but not necessarily active yet)
                if let config = configuration, config.isEnabled, activeBlockRule == nil {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No events today")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Text("Enjoy your free time!")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

#Preview {
    HomeView()
        .environmentObject(AppState())
}

