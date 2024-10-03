import Foundation
import os
import Alamofire

// The Swift Programming Language
// https://docs.swift.org/swift-book
@available(iOS 14.0, *)
@MainActor
class FlockSDK: NSObject {
    private static var flock: FlockSDK?
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: FlockSDK.self)
    )
    private static let baseUrl = URL("https://api.withflock.com")
    
    public private(set) static var isInitialized = false
    
    private var publicAccessKey: String
    private var campaignId: String
    private var session: Session
    
    private init(publicAccessKey: String, campaignId: String) {
        self.publicAccessKey = publicAccessKey
        self.campaignId = campaignId
        
        
        let interceptor = ApiRequestInterceptor(baseURL: "https://api.withflock.com", apiKey: publicAccessKey)
        self.session = Session(interceptor: interceptor)
    }
    
    public static var shared: FlockSDK {
        guard let flock = flock else {
            logger.warning("FlockSDK has not been configured. Please call FlockSDK.configure()")
            assertionFailure("FlockSDK has not been configured. Please call FlockSDK.configure()")
            return FlockSDK(publicAccessKey: "", campaignId: "")
        }
        return flock
    }
    
    @discardableResult
    public static func configure(
        publicAccessKey: String,
        campaignId: String
    ) -> FlockSDK {
        guard flock == nil else {
            return shared
        }
        
        flock = FlockSDK(publicAccessKey: publicAccessKey, campaignId: campaignId)
        isInitialized = true
        return shared
    }
    
    public func ping() -> Void {
        self.session.request("/campaign/\(self.campaignId)/ping").validate()
    }
}
