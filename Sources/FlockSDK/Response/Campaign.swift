//
//  Campaign.swift
//  FlockSDK
//
//  Created by Hoa Nguyen on 2024-10-04.
//


public struct Campaign: Codable, Sendable {
    public let id: String
    public let name: String
    public let createdAt: String
    public let updatedAt: String
    public let environment: FlockEnvironment
    public let isLive: Bool
    public let campaignPages: [CampaignPage]
}

public struct CampaignPage: Codable, Sendable {
    public let id: String
    public let path: String
    public let isEmpty: Bool
    public let url: String
    public let screenProps: ScreenProps?
}

public struct ScreenProps: Codable, Sendable {
    public let backgroundColor: String?
    public let primaryColor: String?
    public let secondaryColor: String?
    public let textColor: String?
    public let fontFamily: String?
}
