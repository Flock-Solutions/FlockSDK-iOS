//
//  RequestBuilder.swift
//  FlockSDK
//
//  Created by Hoa Nguyen on 2024-10-02.
//
import Foundation

enum RequestMethod: String {
    case post = "POST"
    case get = "GET"
    case put = "PUT"
    case patch = "PATCH"
}

struct RequestBuilder {
    private let apiKey: String

    public init(apiKey: String) {
        self.apiKey = apiKey
    }

    public func build(url: URL, method: RequestMethod) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.addValue(apiKey, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        return request
    }
}
