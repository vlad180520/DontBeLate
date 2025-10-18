//
//  UpcomingEventsView.swift
//  DontBeLate
//
//  Created on 2025
//

import SwiftUI

struct UpcomingEventsView: View {
    @StateObject private var viewModel = UpcomingEventsViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.groupedEvents.keys.sorted(), id: \.self) { date in
                    Section(header: Text(formatSectionHeader(date))) {
                        ForEach(viewModel.groupedEvents[date] ?? []) { event in
                            NavigationLink(destination: EventDetailView(event: event)) {
                                UpcomingEventRow(event: event)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Upcoming Events")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.loadEvents()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .onAppear {
                viewModel.loadEvents()
            }
            .refreshable {
                viewModel.loadEvents()
            }
        }
    }
    
    private func formatSectionHeader(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
    }
}

struct UpcomingEventRow: View {
    let event: EventModel
    @StateObject private var configManager = EventConfigurationManager.shared
    @StateObject private var eventMonitor = EventMonitor.shared
    
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
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(event.title)
                    .font(.headline)
                
                Spacer()
                
                // Show traffic icon if using traffic timing
                if let config = configuration, config.useTrafficTiming && event.hasLocation {
                    Image(systemName: "car.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                        .padding(4)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(4)
                }
                
                Text(event.startDate, style: .time)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if let location = event.location {
                HStack(spacing: 5) {
                    Image(systemName: "location.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                    Text(location)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                Image(systemName: "calendar")
                    .font(.caption)
                    .foregroundColor(.orange)
                Text(event.calendar)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
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
        .padding(.vertical, 4)
    }
}

class UpcomingEventsViewModel: ObservableObject {
    @Published var groupedEvents: [Date: [EventModel]] = [:]
    
    private let calendarService = CalendarService.shared
    
    func loadEvents() {
        calendarService.fetchUpcomingEvents(daysAhead: 7) { [weak self] events in
            DispatchQueue.main.async {
                self?.groupEventsByDate(events)
            }
        }
    }
    
    private func groupEventsByDate(_ events: [EventModel]) {
        let calendar = Calendar.current
        
        let grouped = Dictionary(grouping: events) { event in
            calendar.startOfDay(for: event.startDate)
        }
        
        groupedEvents = grouped
    }
}

#Preview {
    UpcomingEventsView()
}

