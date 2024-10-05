//
//  APIClient.swift
//  FlockSDK
//
//  Created by Hoa Nguyen on 2024-10-03.
//
import Foundation

@available(iOS 14.0, *)
struct APIClient {
    private let urlBuilder: URLBuilder
    private let requestBuilder: RequestBuilder
    
    init(apiKey: String, baseURL: String?) {
        self.urlBuilder = URLBuilder(baseURL: baseURL)
        self.requestBuilder = RequestBuilder(apiKey: apiKey)
    }
    
    @discardableResult
    func ping(campaignId: String) async throws -> PingResponse {
        let url = try self.urlBuilder.build(path: "/campaigns/\(campaignId)/ping")
        
        let request = self.requestBuilder.build(url: url, method: .post)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let json = try JSONDecoder().decode(PingResponse.self, from: data)
        return json
    }
    
    @discardableResult
    func identify(identifyRequest: IdentifyRequest) async throws -> Customer {
        let url = try self.urlBuilder.build(path: "/customers/identify")

        let request = self.requestBuilder.build(url: url, method: .post)
        
        let jsonRequest = try JSONEncoder().encode(identifyRequest)
        
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let json = try JSONDecoder().decode(Customer.self, from: data)
        return json
    }
}
