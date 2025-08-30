//
//  CampaignCheckpointService.swift
//  FlockSDK
//
//  Created by Hoa Nguyen on 2024-10-04.
//

import Foundation
import OSLog

@available(iOS 14.0, *)
struct CampaignCheckpointService {
    private let urlBuilder: URLBuilder
    private let requestBuilder: RequestBuilder

    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: Flock.self)
    )

    init(publicAccessKey: String, baseURL: String?) {
        urlBuilder = URLBuilder(baseURL: baseURL)
        requestBuilder = RequestBuilder(apiKey: publicAccessKey)
    }

    func getCampaignCheckpoints(campaignId: String) async throws -> [CampaignCheckpoint] {
        let url = try urlBuilder.build(path: "/campaign-checkpoints")

        var components = try URLComponents(url: url, resolvingAgainstBaseURL: true)
        components?.queryItems = [
            URLQueryItem(name: "campaignId", value: campaignId)
        ]

        guard let finalURL = components?.url else {
            throw URLError(.badURL)
        }

        let request = requestBuilder.build(url: finalURL, method: .get)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, (200 ... 299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let checkpointsResponse = try JSONDecoder().decode(CampaignCheckpointsResponse.self, from: data)
        return checkpointsResponse.data
    }
}
