//
//  CustomerService.swift
//  FlockSDK
//
//  Created by Hoa Nguyen on 2025-06-02.
//

import Foundation
import OSLog

@available(iOS 14.0, *)
struct CustomerService {
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

    func identify(identifyRequest: IdentifyRequest) async throws -> Customer {
        let url = try urlBuilder.build(path: "/customers/identify")
        var request = requestBuilder.build(url: url, method: .post)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(identifyRequest)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, (200 ... 299).contains(httpResponse.statusCode) else {
            logger.error("Failed to identify customer: bad server response.")
            throw URLError(.badServerResponse)
        }

        let customer = try JSONDecoder().decode(Customer.self, from: data)
        return customer
    }
}
