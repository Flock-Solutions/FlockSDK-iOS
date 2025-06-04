//
//  IdentifyResponse.swift
//  FlockSDK
//
//  Created by Hoa Nguyen on 2024-10-02.
//
public struct Customer: Codable, Sendable {
    let id: String
    let externalUserId: String
    let email: String
    let name: String?
    let referralCode: String
    let visitedReferralsCount: Int
    let convertedReferralsCount: Int
    let referredById: String?
}
