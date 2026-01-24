//
//  NWSModels.swift
//  NWSForecast
//
//  Models for NWS API responses
//

import Foundation

// MARK: - Points API Response
struct NWSPointsResponse: Codable {
    let properties: PointsProperties
}

struct PointsProperties: Codable {
    let gridId: String
    let gridX: Int
    let gridY: Int
    let forecast: String
    let forecastOffice: String
    let forecastZone: String
    let relativeLocation: RelativeLocation?
}

struct RelativeLocation: Codable {
    let properties: RelativeLocationProperties
}

struct RelativeLocationProperties: Codable {
    let city: String
    let state: String
}

// MARK: - Products List Response
struct NWSProductsListResponse: Codable {
    let context: [Context]?
    let graph: [Product]

    enum CodingKeys: String, CodingKey {
        case context = "@context"
        case graph = "@graph"
    }
}

struct Context: Codable {
    let version: String?
}

struct Product: Codable {
    let id: String
    let issuanceTime: String

    enum CodingKeys: String, CodingKey {
        case id = "@id"
        case issuanceTime
    }
}

// MARK: - Product Detail Response
struct NWSProductResponse: Codable {
    let id: String
    let productText: String
    let issuanceTime: String

    enum CodingKeys: String, CodingKey {
        case id = "@id"
        case productText
        case issuanceTime
    }
}

// MARK: - App Models
struct AFDData {
    let rawText: String
    let sections: [AFDSection]
    let locationName: String
    let wfoCode: String
    let issuanceTime: Date
    let fetchTime: Date
}

struct AFDSection: Identifiable {
    let id = UUID()
    let title: String
    let content: String
    var isExpanded: Bool = true
}
