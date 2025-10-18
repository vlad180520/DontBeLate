//
//  HomeViewModel.swift
//  DontBeLate
//
//  Created on 2025
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published var todayEvents: [EventModel] = []
    @Published var nextEvent: EventModel?
    @Published var isLoading = false
    @Published var activeBlockingCount = 0
    
    private let calendarService = CalendarService.shared
    private let eventMonitor = EventMonitor.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        eventMonitor.$upcomingEvents
            .sink { [weak self] events in
                self?.updateTodayEvents(events)
            }
            .store(in: &cancellables)
        
        eventMonitor.$activeBlockRules
            .sink { [weak self] rules in
                self?.activeBlockingCount = rules.filter { $0.isActive }.count
            }
            .store(in: &cancellables)
        
        // Subscribe to live calendar changes
        calendarService.calendarDidChange
            .sink { [weak self] in
                print("🔄 Home: Calendar changed, reloading...")
                self?.loadTodayEvents()
            }
            .store(in: &cancellables)
    }
    
    func loadTodayEvents() {
        isLoading = true
        
        // Async loading for better performance
        Task {
            await MainActor.run {
                calendarService.fetchEvents(for: Date()) { [weak self] events in
                    DispatchQueue.main.async {
                        self?.todayEvents = events.sorted { $0.startDate < $1.startDate }
                        self?.updateNextEvent()
                        self?.isLoading = false
                    }
                }
            }
        }
    }
    
    private func updateTodayEvents(_ events: [EventModel]) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        todayEvents = events.filter { event in
            calendar.isDate(event.startDate, inSameDayAs: today)
        }.sorted { $0.startDate < $1.startDate }
        
        updateNextEvent()
    }
    
    private func updateNextEvent() {
        nextEvent = todayEvents.first { $0.startDate > Date() }
    }
    
    func refreshEvents() {
        loadTodayEvents()
        eventMonitor.refreshEvents()
    }
    
    func timeUntilNextEvent() -> String? {
        guard let nextEvent = nextEvent else { return nil }
        
        let timeInterval = nextEvent.startDate.timeIntervalSince(Date())
        
        if timeInterval < 0 {
            return "In progress"
        }
        
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

