//
//  LocationManager.swift
//  NWSForecast
//
//  Handles location permissions and updates
//

import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()

    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var locationError: Error?

    // Default fallback location (San Francisco)
    static let defaultLocation = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)

    override init() {
        self.authorizationStatus = locationManager.authorizationStatus
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    func requestLocation() {
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied, .restricted:
            currentLocation = Self.defaultLocation
        @unknown default:
            currentLocation = Self.defaultLocation
        }
    }

    func searchLocation(query: String) async throws -> CLLocationCoordinate2D {
        return try await withCheckedThrowingContinuation { continuation in
            geocoder.geocodeAddressString(query) { placemarks, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let location = placemarks?.first?.location else {
                    continuation.resume(throwing: NSError(
                        domain: "LocationManager",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Location not found"]
                    ))
                    return
                }

                continuation.resume(returning: location.coordinate)
            }
        }
    }

    func reverseGeocode(coordinate: CLLocationCoordinate2D) async throws -> String {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return try await withCheckedThrowingContinuation { continuation in
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let placemark = placemarks?.first else {
                    continuation.resume(throwing: NSError(
                        domain: "LocationManager",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Could not determine location name"]
                    ))
                    return
                }

                let city = placemark.locality ?? "Unknown"
                let state = placemark.administrativeArea ?? ""
                let name = state.isEmpty ? city : "\(city), \(state)"
                continuation.resume(returning: name)
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        currentLocation = location.coordinate
        locationError = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationError = error
        currentLocation = Self.defaultLocation
    }
}
