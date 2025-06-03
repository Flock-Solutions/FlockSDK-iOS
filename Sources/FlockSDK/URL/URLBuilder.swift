//
//  URLBuilder.swift
//  FlockSDK
//
//  Created by Hoa Nguyen on 2024-10-02.
//
import Foundation

internal struct URLBuilder {
    private let baseURL: URL?
    
    init(baseURL: String? = nil) {
        self.baseURL = URL(string: baseURL ?? "https://api.withflock.com")
    }
    
    func build(path: String) throws -> URL {
        guard self.baseURL != nil, let url = URL(string: path, relativeTo: self.baseURL) else {
            throw URLError(.badURL)
        }
        
        return url
    }
}
