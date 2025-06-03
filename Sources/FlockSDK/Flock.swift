import Foundation
import SwiftUI
import UIKit
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
    
    private(set) var isInitialized = false
    
    private let publicAccessKey: String
    private let environment: FlockEnvironment
    private var campaign: Campaign?
    private var customer: Customer?
    
    private let campaignService: CampaignService
    private let customerService: CustomerService
    
    private init(publicAccessKey: String, environment: FlockEnvironment, overrideApiURL: String? = nil) {
        self.publicAccessKey = publicAccessKey
        self.environment = environment
        self.campaignService = CampaignService(publicAccessKey: self.publicAccessKey, baseURL: overrideApiURL)
        self.customerService = CustomerService(publicAccessKey: self.publicAccessKey, baseURL: overrideApiURL)
    }
    
    public static func shared() throws -> Flock {
        guard let flock = flock else {
            logger.warning("FlockSDK has not been initialized. Please call FlockSDK.initialized()")
            assertionFailure("FlockSDK has not been initialized. Please call FlockSDK.initialized()")
            throw FlockSDKErrors.uninitialized("FlockSDK has not been initialized. Please call FlockSDK.initialized()")
        }
        return flock
    }
    
    @discardableResult
    public static func initialize(
        publicAccessKey: String,
        environment: FlockEnvironment,
        overrideApiURL: String? = nil
    ) throws -> Flock {
        guard flock == nil else {
            logger.warning("FlockSDK has already been initialized. Please call FlockSDK.initialized() only once")
            throw FlockSDKErrors.uninitialized("FlockSDK has already been initialized. Please call FlockSDK.initialized() only once")
        }
        
        let instance = Flock(publicAccessKey: publicAccessKey, environment: environment, overrideApiURL: overrideApiURL)
        flock = instance
        
        // Fetch live campaign from Flock
        Task { @MainActor in
            var campaign: Campaign? = nil
            do {
                campaign = try await instance.campaignService.getLiveCampaign(environment: environment)
                instance.campaign = campaign
            } catch {
                logger.error("Error fetching live campaign during initialization: \(error)")
            }
            
            guard let campaign = campaign else { return }
            do {
                try await instance.campaignService.ping(campaignId: campaign.id)
            } catch {
                logger.error("Error pinging campaign during initialization: \(error)")
            }
        }
        
        instance.isInitialized = true
        
        return instance
    }
    
    
    /**
     Identifies a customer to keep a record in Flock.

     - Parameters:
        - externalUserId: The unique identifier for the user in your system.
        - email: The customer's email address.
        - name: The customer's name (optional).

     - Throws: `FlockSDKErrors.uninitialized` if SDK is not initialized.
     */
    public func identify(externalUserId: String, email: String, name: String?) throws -> Void {
        guard isInitialized else {
            throw FlockSDKErrors.uninitialized("FlockSDK is not initialized. Please call FlockSDK.initialize() first")
        }
        
        Task {
            guard let campaign else { return }
            do {
                let identifyRequest = IdentifyRequest(externalUserId: externalUserId, email: email, name: name, campaignId: campaign.id)
                customer = try await customerService.identify(identifyRequest: identifyRequest)
            } catch {
                Flock.logger.error("Error identifying customer: \(error)")
            }
        }
    }
    
    /**
     Opens a Flock web page in a modal or fullscreen style.

     - Parameters:
        - type: The page type or path to open
        - style: Presentation style (.modal or .fullscreen). Default is .fullscreen.
        - onClose: Callback executed when the page is closed.
        - onSuccess: Callback executed when the page reports a success event.
        - onInvalid: Callback executed when the page reports an invalid event.

     - Throws: `FlockSDKErrors.uninitialized` if SDK is not initialized.
     */
    public func openPage(
        type: String,
        style: WebViewPresentationStyle = .fullscreen,
        onClose: (() -> Void)? = nil,
        onSuccess: (() -> Void)? = nil,
        onInvalid: (() -> Void)? = nil
    ) throws {
        guard isInitialized else {
            throw FlockSDKErrors.uninitialized("FlockSDK is not initialized. Please call FlockSDK.initialize() first")
        }
        guard let url = buildWebPageURL(type: type) else {
            Flock.logger.error("Cannot build web page URL for type: \(type)")
            return
        }
        
        let webViewController = WebViewController(
            url: url,
            onClose: onClose,
            onSuccess: onSuccess,
            onInvalid: onInvalid
        )
        
        guard let topViewController = UIApplication.shared.topMostViewController(),
              topViewController.presentedViewController == nil else { return }

        switch style {
        case .modal:
            topViewController.present(webViewController, animated: true)
        case .fullscreen:
            webViewController.modalPresentationStyle = .overFullScreen
            topViewController.present(webViewController, animated: true)
        }
    }
    
    private func buildWebPageURL(type: String) -> URL? {
        // Split type into path and query
        let parts = type.split(separator: "?", maxSplits: 1, omittingEmptySubsequences: false)
        let path = String(parts.first ?? "")
        let query = parts.count > 1 ? String(parts[1]) : ""

        // Find the campaign page for this type
        let campaignPage = campaign?.campaignPages.first { $0.path.contains(path) }

        // Use backgroundColor if available
        let backgroundColor = campaignPage?.screenProps?.backgroundColor

        // Prepare base url
        let appBaseURL = "https://app.withflock.com"

        // Build URL string
        var urlString = "\(appBaseURL)/pages/\(path)?key=\(publicAccessKey)"
        
        if let campaignId = campaign?.id {
            urlString += "&campaign_id=\(campaignId)"
        }
        
        if let customerId = customer?.id {
            urlString += "&customer_id=\(customerId)"
        }
        
        if let backgroundColor = backgroundColor {
            urlString += "&bg=\(backgroundColor)"
        }
        
        if !query.isEmpty {
            urlString += "&\(query)"
        }

        return URL(string: urlString)
    }
}
