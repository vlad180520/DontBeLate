//
//  LocationService.swift
//  DontBeLate
//
//  Created on 2025
//

import Foundation
import CoreLocation
import MapKit

class LocationService: NSObject, ObservableObject {
    static let shared = LocationService()
    
    private let locationManager = CLLocationManager()
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func checkAuthorizationStatus(completion: @escaping (Bool) -> Void) {
        let status = locationManager.authorizationStatus
        authorizationStatus = status
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            completion(true)
        case .notDetermined:
            requestAuthorization()
            completion(false)
        default:
            completion(false)
        }
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    // Get current location asynchronously
    func getCurrentLocation() async -> CLLocation? {
        // If we already have a recent location, return it
        if let location = currentLocation,
           Date().timeIntervalSince(location.timestamp) < 300 { // Less than 5 minutes old
            return location
        }
        
        // Otherwise request fresh location
        return await withCheckedContinuation { continuation in
            startUpdatingLocation()
            
            // Wait for location update with timeout
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
                self?.stopUpdatingLocation()
                continuation.resume(returning: self?.currentLocation)
            }
        }
    }
    
    // Calculate travel time to destination
    func calculateTravelTime(
        to destination: CLLocationCoordinate2D,
        transportType: TransportType,
        completion: @escaping (TimeInterval?, Error?) -> Void
    ) {
        guard let currentLocation = currentLocation else {
            completion(nil, NSError(domain: "LocationService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Current location not available"]))
            return
        }
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: currentLocation.coordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        
        // Set transport type
        switch transportType {
        case .automobile:
            request.transportType = .automobile
        case .walking:
            request.transportType = .walking
        case .transit:
            request.transportType = .transit
        }
        
        request.requestsAlternateRoutes = false
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let route = response?.routes.first else {
                completion(nil, NSError(domain: "LocationService", code: 2, userInfo: [NSLocalizedDescriptionKey: "No route found"]))
                return
            }
            
            // Return expected travel time in seconds
            completion(route.expectedTravelTime, nil)
        }
    }
    
    // Calculate travel time with traffic consideration
    func calculateTravelTimeWithTraffic(
        to destination: CLLocationCoordinate2D,
        completion: @escaping (TimeInterval?, Error?) -> Void
    ) {
        guard let currentLocation = currentLocation else {
            completion(nil, NSError(domain: "LocationService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Current location not available"]))
            return
        }
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: currentLocation.coordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.transportType = .automobile
        request.requestsAlternateRoutes = false
        
        let directions = MKDirections(request: request)
        directions.calculateETA { response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let eta = response else {
                completion(nil, NSError(domain: "LocationService", code: 3, userInfo: [NSLocalizedDescriptionKey: "ETA not available"]))
                return
            }
            
            // Return expected arrival time (includes current traffic)
            completion(eta.expectedTravelTime, nil)
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdatingLocation()
        default:
            stopUpdatingLocation()
        }
    }
}

