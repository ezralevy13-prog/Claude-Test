//
//  WeatherViewModel.swift
//  NWSForecast
//
//  Main view model for weather data
//

import Foundation
import CoreLocation
import Combine

@MainActor
class WeatherViewModel: ObservableObject {
    @Published var afdData: AFDData?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var locationName: String = "San Francisco, CA"
    @Published var isOffline = false
    @Published var searchText = ""
    @Published var isSearching = false

    private let nwsService = NWSService.shared
    private let locationManager = LocationManager()
    private var cancellables = Set<AnyCancellable>()

    private let cacheKey = "cachedAFDData"
    private let cacheTimeKey = "cachedAFDTime"
    private let cacheLocationKey = "cachedLocation"

    var lastUpdateText: String {
        guard let data = afdData else { return "" }
        let interval = Date().timeIntervalSince(data.fetchTime)
        let minutes = Int(interval / 60)

        if minutes < 1 {
            return "Updated just now"
        } else if minutes == 1 {
            return "Updated 1 min ago"
        } else if minutes < 60 {
            return "Updated \(minutes) min ago"
        } else {
            let hours = minutes / 60
            return hours == 1 ? "Updated 1 hour ago" : "Updated \(hours) hours ago"
        }
    }

    init() {
        setupLocationObserver()
        loadCachedData()
    }

    private func setupLocationObserver() {
        locationManager.$currentLocation
            .compactMap { $0 }
            .sink { [weak self] coordinate in
                Task { @MainActor [weak self] in
                    await self?.fetchAFD(for: coordinate)
                }
            }
            .store(in: &cancellables)
    }

    func requestInitialLocation() {
        locationManager.requestLocation()
    }

    func refreshLocation() {
        locationManager.requestLocation()
    }

    func refresh() async {
        if let coordinate = locationManager.currentLocation {
            await fetchAFD(for: coordinate)
        } else {
            await fetchAFD(for: LocationManager.defaultLocation)
        }
    }

    func searchLocation(_ query: String) async {
        guard !query.isEmpty else { return }

        isSearching = true
        errorMessage = nil

        do {
            let coordinate = try await locationManager.searchLocation(query: query)
            await fetchAFD(for: coordinate)
        } catch {
            errorMessage = "Could not find location: \(error.localizedDescription)"
        }

        isSearching = false
    }

    func toggleSection(_ sectionId: UUID) {
        guard var data = afdData else { return }

        if let index = data.sections.firstIndex(where: { $0.id == sectionId }) {
            data.sections[index].isExpanded.toggle()
            afdData = data
        }
    }

    func shareText() -> String {
        guard let data = afdData else { return "" }

        var text = "Area Forecast Discussion - \(data.locationName)\n"
        text += "Issued: \(formatDate(data.issuanceTime))\n\n"

        for section in data.sections {
            text += "\(section.title.uppercased())\n"
            text += "\(section.content)\n\n"
        }

        return text
    }

    private func fetchAFD(for coordinate: CLLocationCoordinate2D) async {
        isLoading = true
        errorMessage = nil
        isOffline = false

        do {
            let data = try await nwsService.fetchAFD(for: coordinate)
            afdData = data
            locationName = data.locationName
            cacheData(data, coordinate: coordinate)
        } catch {
            errorMessage = error.localizedDescription
            isOffline = true

            // Show cached data if available
            if afdData == nil {
                loadCachedData()
            }
        }

        isLoading = false
    }

    // MARK: - Caching

    private func cacheData(_ data: AFDData, coordinate: CLLocationCoordinate2D) {
        let encoder = JSONEncoder()

        do {
            // Cache the raw text and metadata
            let cacheData = CachedAFDData(
                rawText: data.rawText,
                locationName: data.locationName,
                wfoCode: data.wfoCode,
                issuanceTime: data.issuanceTime,
                fetchTime: data.fetchTime,
                latitude: coordinate.latitude,
                longitude: coordinate.longitude
            )

            let encoded = try encoder.encode(cacheData)
            UserDefaults.standard.set(encoded, forKey: cacheKey)
            UserDefaults.standard.set(Date(), forKey: cacheTimeKey)
        } catch {
            print("Failed to cache data: \(error)")
        }
    }

    private func loadCachedData() {
        guard let data = UserDefaults.standard.data(forKey: cacheKey) else { return }

        let decoder = JSONDecoder()
        do {
            let cached = try decoder.decode(CachedAFDData.self, from: data)
            let sections = AFDParser.parse(cached.rawText)

            afdData = AFDData(
                rawText: cached.rawText,
                sections: sections,
                locationName: cached.locationName,
                wfoCode: cached.wfoCode,
                issuanceTime: cached.issuanceTime,
                fetchTime: cached.fetchTime
            )

            locationName = cached.locationName
            isOffline = true

            // Trigger background refresh
            Task {
                await refresh()
            }
        } catch {
            print("Failed to load cached data: \(error)")
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Cacheable Model
private struct CachedAFDData: Codable {
    let rawText: String
    let locationName: String
    let wfoCode: String
    let issuanceTime: Date
    let fetchTime: Date
    let latitude: Double
    let longitude: Double
}
