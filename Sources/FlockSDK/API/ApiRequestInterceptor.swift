//
//  RequestInterceptor.swift
//  FlockSDK
//
//  Created by Hoa Nguyen on 2024-10-02.
//
import Foundation
import Alamofire

class ApiRequestInterceptor: RequestInterceptor {
    private let baseURL: URL
    private let apiKey: String
    
    init(baseURL: URL, apiKey: String) {
        self.baseURL = baseURL
        self.apiKey = apiKey
    }
    
    convenience init(baseURL: String, apiKey: String) {
        self.init(baseURL: URL(string: baseURL)!, apiKey: apiKey)
    }
    
    // Adapt the request to include the base URL and API key
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var adaptedRequest = urlRequest
        
        // Prepend the base URL if the URL is relative (no host)
        if let url = adaptedRequest.url, url.host == nil {
            adaptedRequest.url = URL(string: url.absoluteString, relativeTo: baseURL)
        }
        
        // Add the API key to the "Authorization" header
        adaptedRequest.setValue(apiKey, forHTTPHeaderField: "Authorization")
        
        completion(.success(adaptedRequest))
    }
}
