//
//  NWSService.swift
//  NWSForecast
//
//  Service for fetching data from NWS API
//

import Foundation
import CoreLocation

enum NWSError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case noProducts
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to parse data: \(error.localizedDescription)"
        case .noProducts:
            return "No forecast discussions available"
        case .invalidResponse:
            return "Invalid response from server"
        }
    }
}

class NWSService {
    static let shared = NWSService()

    private let session: URLSession
    private let baseURL = "https://api.weather.gov"

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        self.session = URLSession(configuration: config)
    }

    // MARK: - Public API

    func fetchAFD(for coordinate: CLLocationCoordinate2D) async throws -> AFDData {
        // Step 1: Get WFO code from coordinates
        let pointsData = try await fetchPointsData(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let wfoCode = pointsData.properties.gridId
        let cityName = pointsData.properties.relativeLocation?.properties.city ?? "Unknown"
        let stateName = pointsData.properties.relativeLocation?.properties.state ?? ""
        let locationName = stateName.isEmpty ? cityName : "\(cityName), \(stateName)"

        // Step 2: Get latest AFD product ID for this WFO
        let productID = try await fetchLatestAFDProductID(wfo: wfoCode)

        // Step 3: Get the full product text
        let productData = try await fetchProductDetail(productID: productID)

        // Step 4: Parse the product text
        let sections = AFDParser.parse(productData.productText)

        let issuanceDate = ISO8601DateFormatter().date(from: productData.issuanceTime) ?? Date()

        return AFDData(
            rawText: productData.productText,
            sections: sections,
            locationName: locationName,
            wfoCode: wfoCode,
            issuanceTime: issuanceDate,
            fetchTime: Date()
        )
    }

    // MARK: - Private Methods

    private func fetchPointsData(latitude: Double, longitude: Double) async throws -> NWSPointsResponse {
        let urlString = "\(baseURL)/points/\(latitude),\(longitude)"
        guard let url = URL(string: urlString) else {
            throw NWSError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue("NWSForecastApp/1.0", forHTTPHeaderField: "User-Agent")

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw NWSError.invalidResponse
            }

            let decoder = JSONDecoder()
            return try decoder.decode(NWSPointsResponse.self, from: data)
        } catch let error as NWSError {
            throw error
        } catch let error as DecodingError {
            throw NWSError.decodingError(error)
        } catch {
            throw NWSError.networkError(error)
        }
    }

    private func fetchLatestAFDProductID(wfo: String) async throws -> String {
        let urlString = "\(baseURL)/products/types/AFD/locations/\(wfo)"
        guard let url = URL(string: urlString) else {
            throw NWSError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue("NWSForecastApp/1.0", forHTTPHeaderField: "User-Agent")

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw NWSError.invalidResponse
            }

            let decoder = JSONDecoder()
            let productsResponse = try decoder.decode(NWSProductsListResponse.self, from: data)

            guard let latestProduct = productsResponse.graph.first else {
                throw NWSError.noProducts
            }

            return latestProduct.id
        } catch let error as NWSError {
            throw error
        } catch let error as DecodingError {
            throw NWSError.decodingError(error)
        } catch {
            throw NWSError.networkError(error)
        }
    }

    private func fetchProductDetail(productID: String) async throws -> NWSProductResponse {
        guard let url = URL(string: productID) else {
            throw NWSError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue("NWSForecastApp/1.0", forHTTPHeaderField: "User-Agent")

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw NWSError.invalidResponse
            }

            let decoder = JSONDecoder()
            return try decoder.decode(NWSProductResponse.self, from: data)
        } catch let error as NWSError {
            throw error
        } catch let error as DecodingError {
            throw NWSError.decodingError(error)
        } catch {
            throw NWSError.networkError(error)
        }
    }
}
