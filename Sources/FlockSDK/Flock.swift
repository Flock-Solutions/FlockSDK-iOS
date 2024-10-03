import Foundation
import os

// The Swift Programming Language
// https://docs.swift.org/swift-book
@available(iOS 14.0, *)
@MainActor
public class Flock: NSObject {
    private static var flock: Flock?
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: Flock.self)
    )
    
    public private(set) static var isInitialized = false
    
    private var publicAccessKey: String
    private var campaignId: String
    private var baseApiURL: URL
    
    private init(publicAccessKey: String, campaignId: String, overrideApiURL: String? = nil) {
        self.publicAccessKey = publicAccessKey
        self.campaignId = campaignId
        self.baseApiURL = URL(string: overrideApiURL ?? "https://api.withflock.com")!
    }
    
    public static var shared: Flock {
        guard let flock = flock else {
            logger.warning("FlockSDK has not been configured. Please call FlockSDK.configure()")
            assertionFailure("FlockSDK has not been configured. Please call FlockSDK.configure()")
            return Flock(publicAccessKey: "", campaignId: "")
        }
        return flock
    }
    
    @discardableResult
    public static func configure(
        publicAccessKey: String,
        campaignId: String,
        overrideApiURL: String? = nil
    ) -> Flock {
        guard flock == nil else {
            logger.warning("FlockSDK has already been configured. Please call FlockSDK.configure() only once")
            return shared
        }
        
        flock = Flock(publicAccessKey: publicAccessKey, campaignId: campaignId, overrideApiURL: overrideApiURL)
        isInitialized = true
        
        Task {
            do {
                let response = try await flock?.ping()
                let id = response?.id ?? ""
                print("Pinged \(id)")
            } catch {
                print("Error pinging server:", error)
            }
        }
        
        return shared
    }
    
    /**
     Ping the server to make sure the integration is working
     */
    public func ping() async throws -> PingResponse {
        guard let url = URL(string: "/campaigns/\(self.campaignId)/ping", relativeTo: self.baseApiURL) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(self.publicAccessKey, forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        print("Response: \(response). Data: \(data)")
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let json = try JSONDecoder().decode(PingResponse.self, from: data)
        return json
    }
}
