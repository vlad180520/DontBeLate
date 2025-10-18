//
//  ConvexClient.swift
//  DontBeLate
//
//  Convex backend client for syncing user data, events, and blocking sessions
//

import Foundation

class ConvexClient {
    static let shared = ConvexClient()
    
    private let baseURL = "https://hallowed-viper-24.convex.cloud"
    
    private init() {}
    
    // MARK: - Core API Methods
    
    func mutation(_ name: String, with args: [String: Any]) async throws -> Any {
        return try await callFunction(type: "mutation", name: name, args: args)
    }
    
    func query(_ name: String, with args: [String: Any]) async throws -> Any {
        return try await callFunction(type: "query", name: name, args: args)
    }
    
    func action(_ name: String, with args: [String: Any]) async throws -> Any {
        return try await callFunction(type: "action", name: name, args: args)
    }
    
    private func callFunction(type: String, name: String, args: [String: Any]) async throws -> Any {
        let parts = name.split(separator: ":")
        guard parts.count == 2 else {
            throw ConvexError.invalidFunctionName
        }
        
        let url = URL(string: "\(baseURL)/api/\(type)/\(parts[0])/\(parts[1])")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["args": args]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ConvexError.httpError
        }
        
        if httpResponse.statusCode != 200 {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ Convex API Error (\(httpResponse.statusCode)): \(errorMessage)")
            throw ConvexError.httpError
        }
        
        let json = try JSONSerialization.jsonObject(with: data)
        if let dict = json as? [String: Any], let value = dict["value"] {
            return value
        }
        
        return json
    }
    
    // MARK: - User Management
    
    func upsertUser(
        userId: String,
        email: String?,
        defaultPreEventTime: Int,
        blockedApps: [String],
        notificationsEnabled: Bool,
        locationBasedTimingEnabled: Bool
    ) async throws -> String {
        let result = try await mutation("users:upsertUser", with: [
            "userId": userId,
            "email": email ?? "",
            "defaultPreEventTime": defaultPreEventTime,
            "blockedApps": blockedApps,
            "notificationsEnabled": notificationsEnabled,
            "locationBasedTimingEnabled": locationBasedTimingEnabled
        ])
        
        if let userId = result as? String {
            print("✅ User synced to backend: \(userId)")
            return userId
        }
        
        throw ConvexError.invalidResponse
    }
    
    func getUser(userId: String) async throws -> [String: Any]? {
        let result = try await query("users:getUser", with: ["userId": userId])
        return result as? [String: Any]
    }
    
    // MARK: - Event Management
    
    func syncCalendarEvents(userId: String, events: [[String: Any]]) async throws -> [String: Any] {
        let result = try await mutation("events:syncCalendarEvents", with: [
            "userId": userId,
            "events": events
        ])
        
        if let resultDict = result as? [String: Any] {
            print("✅ Synced \(events.count) events to backend")
            return resultDict
        }
        
        throw ConvexError.invalidResponse
    }
    
    func getUpcomingEvents(userId: String, fromTime: Int) async throws -> [[String: Any]] {
        let result = try await query("events:getUpcomingEvents", with: [
            "userId": userId,
            "fromTime": fromTime
        ])
        
        if let events = result as? [[String: Any]] {
            return events
        }
        
        return []
    }
    
    // MARK: - Travel Time Calculation
    
    func calculateTravelTime(
        eventId: String,
        userLat: Double,
        userLng: Double
    ) async throws -> [String: Any]? {
        do {
            let result = try await action("eventProcessor:calculateTravelTimeForEvent", with: [
                "eventId": eventId,
                "userLat": userLat,
                "userLng": userLng
            ])
            
            if let travelData = result as? [String: Any] {
                print("✅ Travel time from backend: \(travelData)")
                return travelData
            }
        } catch {
            print("⚠️ Travel time calculation failed (backend may not have API configured): \(error)")
            return nil
        }
        
        return nil
    }
    
    // MARK: - Blocking Sessions
    
    func getActiveBlockingSessions(userId: String) async throws -> [[String: Any]] {
        let result = try await query("blocking:getActiveBlockingSessions", with: [
            "userId": userId
        ])
        
        if let sessions = result as? [[String: Any]] {
            return sessions
        }
        
        return []
    }
    
    func endBlockingSession(userId: String, eventId: String) async throws -> Bool {
        let result = try await mutation("blocking:endBlockingSession", with: [
            "userId": userId,
            "eventId": eventId
        ])
        
        if let success = result as? Bool {
            return success
        }
        
        return false
    }
}

enum ConvexError: Error {
    case invalidFunctionName
    case invalidResponse
    case httpError
    
    var localizedDescription: String {
        switch self {
        case .invalidFunctionName:
            return "Invalid Convex function name format"
        case .invalidResponse:
            return "Invalid response from Convex backend"
        case .httpError:
            return "HTTP error when calling Convex backend"
        }
    }
}

