import Foundation
import os
import Alamofire

// The Swift Programming Language
// https://docs.swift.org/swift-book
@available(iOS 14.0, *)
@MainActor
class Flock: NSObject {
    private static var flock: Flock?
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: Flock.self)
    )
    private static let baseUrl = URL("https://api.withflock.com")
    
    public private(set) static var isInitialized = false
    
    private var publicAccessKey: String
    private var campaignId: String
    private var session: Session
    
    private init(publicAccessKey: String, campaignId: String, overrideApiURL: String? = nil) {
        self.publicAccessKey = publicAccessKey
        self.campaignId = campaignId
        
        
        let interceptor = ApiRequestInterceptor(baseURL: overrideApiURL ?? "https://api.withflock.com", apiKey: publicAccessKey)
        self.session = Session(interceptor: interceptor)
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
        flock?.ping()
        
        return shared
    }
    
    /**
     Ping the server to make sure the integration is working
     */
    public func ping() -> Void {
        self.session.request("/campaign/\(self.campaignId)/ping").validate()
    }
}
