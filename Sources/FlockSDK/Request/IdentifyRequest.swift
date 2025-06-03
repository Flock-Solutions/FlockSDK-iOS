//
//  IdentifyRequest.swift
//  FlockSDK
//
//  Created by Hoa Nguyen on 2024-10-02.
//

internal struct IdentifyRequest: Encodable {
    let externalUserId: String
    let email: String
    let name: String?
    let campaignId: String
}
