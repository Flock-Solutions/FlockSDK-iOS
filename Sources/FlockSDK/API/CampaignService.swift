//
//  CampaignService.swift
//  FlockSDK
//
//  Created by Hoa Nguyen on 2024-10-04.
//

import Foundation
import OSLog

@available(iOS 14.0, *)
struct CampaignService {
  private let urlBuilder: URLBuilder
  private let requestBuilder: RequestBuilder

  private let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier!,
    category: String(describing: Flock.self)
  )

  init(publicAccessKey: String, baseURL: String?) {
    urlBuilder = URLBuilder(baseURL: baseURL ?? "https://api.withflock.com")
    requestBuilder = RequestBuilder(apiKey: publicAccessKey)
  }

  func getLiveCampaign(environment: FlockEnvironment) async throws -> Campaign {
    var components = try URLComponents(url: urlBuilder.build(path: "/campaigns/live"), resolvingAgainstBaseURL: false)
    components?.queryItems = [
      URLQueryItem(name: "environment", value: environment.rawValue)
    ]
    guard let url = components?.url else {
      throw URLError(.badURL)
    }

    let request = requestBuilder.build(url: url, method: .get)

    let (data, response) = try await URLSession.shared.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse, (200 ... 299).contains(httpResponse.statusCode) else {
      throw URLError(.badServerResponse)
    }

    let campaign = try JSONDecoder().decode(Campaign.self, from: data)
    return campaign
  }

  @discardableResult
  func ping(campaignId: String) async throws -> PingResponse {
    let url = try urlBuilder.build(path: "/campaigns/\(campaignId)/ping")

    let request = requestBuilder.build(url: url, method: .post)

    let (data, response) = try await URLSession.shared.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse, (200 ... 299).contains(httpResponse.statusCode) else {
      throw URLError(.badServerResponse)
    }

    let json = try JSONDecoder().decode(PingResponse.self, from: data)
    return json
  }
}
