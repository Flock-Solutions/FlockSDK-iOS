@_exported import Foundation
@_exported import os
@_exported import SwiftUI
@_exported import UIKit

@available(iOS 14.0, *)
@MainActor
public class Flock: NSObject {
    public static let shared = Flock()

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: Flock.self)
    )

    private var identifyCompletionHandlers: [() -> Void] = []

    /** Views */
    private var webViewController: WebViewController?

    /** Entities */
    private var publicAccessKey: String?
    private var environment: FlockEnvironment?
    private var campaign: Campaign?
    private var customer: Customer?
    private var campaignCheckpoints: [CampaignCheckpoint]?

    /** Services */
    private var campaignService: CampaignService?
    private var customerService: CustomerService?
    private var campaignCheckpointService: CampaignCheckpointService?

    /** Base URLs */
    private var uiBaseUrl: String = "https://app.withflock.com"
    private var apiBaseUrl: String = "https://api.withflock.com"

    /**
     For internal/testing use only: allows overriding the base URLs (e.g. in a sample app)
     */
    public func setBaseUrlForTesting(uiUrl: String, apiUrl: String) {
        uiBaseUrl = uiUrl
        apiBaseUrl = apiUrl
    }

    override private init() {}

    public func initialize(
        publicAccessKey: String,
        environment: FlockEnvironment,
        overrideApiURL: String? = nil,
        completion: ((Bool) -> Void)? = nil
    ) {
        self.publicAccessKey = publicAccessKey
        self.environment = environment
        campaignService = CampaignService(publicAccessKey: publicAccessKey, baseURL: overrideApiURL ?? apiBaseUrl)
        customerService = CustomerService(publicAccessKey: publicAccessKey, baseURL: overrideApiURL ?? apiBaseUrl)
        campaignCheckpointService = CampaignCheckpointService(publicAccessKey: publicAccessKey, baseURL: overrideApiURL ?? apiBaseUrl)
        completion?(true)
    }

    /**
     Identifies a customer to keep a record in Flock.

     - Parameters:
        - externalUserId: The unique identifier for the user in your system.
        - email: The customer's email address.
        - name: The customer's name (optional).
        - customProperties: Optional custom properties for the customer (string | number | boolean | null values only).
     */
    public func identify(externalUserId: String, email: String, name: String, customProperties: CustomProperties? = nil) {
        Task {
            guard let environment = self.environment else { return }
            guard let customerService = self.customerService else { return }
            guard let campaignService = self.campaignService else { return }

            do {
                let identifyRequest = IdentifyRequest(
                    externalUserId: externalUserId, email: email, name: name, customProperties: customProperties
                )

                self.customer = try await customerService.identify(identifyRequest: identifyRequest)

                // Fetch the live campaign after identifying the customer
                guard let customerId = self.customer?.id else { return }
                self.campaign = try await campaignService.getLiveCampaign(environment: environment, customerId: customerId)

                // Fetch campaign checkpoints after getting the campaign
                if let campaignId = self.campaign?.id {
                    self.campaignCheckpoints = try await self.getCampaignCheckpoints(campaignId: campaignId)
                }

                // Run all queued handlers after identify is complete
                let handlers = self.identifyCompletionHandlers
                self.identifyCompletionHandlers.removeAll()
                handlers.forEach { $0() }
            } catch {
                Flock.logger.error("Error identifying customer or fetching campaign: \(error)")
            }
        }
    }

    /**
     Creates a builder for configuring and executing a checkpoint.

     - Parameter name: The name of the checkpoint to trigger.
     - Returns: A CheckpointBuilder instance for method chaining.
     */
    public func checkpoint(_ name: String) -> CheckpointBuilder {
        CheckpointBuilder(name: name, flock: self)
    }

    /**
     Adds a placement to the current campaign.

     - Parameters:
        - placementId: The unique identifier for the placement
        - queryParams: Optional query parameters appended to the placement URL
        - onClose: Callback executed when the placement is closed.
        - onSuccess: Callback executed when the placement reports a success event.
        - onInvalid: Callback executed when the placement reports an invalid event.
     */
    @available(*, deprecated, message: "Use checkpoint(checkpointName:) instead")
    public func addPlacement(
        placementId: String,
        onClose: (() -> Void)? = nil,
        onSuccess: ((Flock) -> Void)? = nil,
        onInvalid: ((Flock) -> Void)? = nil,
        queryParams: [String: String]? = nil
    ) {
        guard customer != nil, campaign != nil else {
            // Queue this call until after identify completes
            Flock.logger.debug("Customer not identified. Queuing addPlacement call...")

            identifyCompletionHandlers.append { [weak self] in
                self?.addPlacement(placementId: placementId, onClose: onClose, onSuccess: onSuccess, onInvalid: onInvalid)
            }
            return
        }

        // Dismiss existing webview controller
        self.webViewController?.dismiss(animated: true)

        guard let url = buildWebPageURL(placementId: placementId, queryParams: queryParams) else {
            Flock.logger.error("Cannot build web page URL for placementId: \(placementId)")
            return
        }

        // Find the campaign page for this placement by placementId or id
        let campaignPage = campaign?.campaignPages.first { page in
            page.placementId == placementId || page.id == placementId
        }

        // Use backgroundColor if available
        let backgroundColor = campaignPage?.screenProps?.backgroundColor

        let webViewController = WebViewController(
            url: url,
            backgroundColorHex: backgroundColor,
            onClose: onClose,
            onSuccess: { _ in
                onSuccess?(self)
            },
            onInvalid: { _ in
                onInvalid?(self)
            }
        )
        self.webViewController = webViewController

        guard let topViewController = UIApplication.shared.topMostViewController(),
              topViewController.presentedViewController == nil
        else { return }

        webViewController.modalPresentationStyle = .fullScreen
        topViewController.present(webViewController, animated: true)
    }

    @available(*, deprecated, message: "Use checkpoint(checkpointName:) instead")
    public func navigate(placementId: String, queryParams: [String: String]? = nil) {
        guard let webViewController else {
            return
        }

        guard let url = buildWebPageURL(placementId: placementId, queryParams: queryParams) else {
            Flock.logger.error("Cannot build web page URL for placementId: \(placementId)")
            return
        }

        // Find the campaign page for this placement by placementId or id
        let campaignPage = campaign?.campaignPages.first { page in
            page.placementId == placementId || page.id == placementId
        }

        // Use backgroundColor if available
        if let backgroundColor = campaignPage?.screenProps?.backgroundColor {
            webViewController.setBackgroundColor(hex: backgroundColor)
        }

        webViewController.loadURL(url: url)
    }

    private func buildWebPageURL(placementId: String, queryParams: [String: String]? = nil) -> URL? {
        // Prepare base url
        let uiBaseUrl = uiBaseUrl

        // Build URL string
        var urlString = "\(uiBaseUrl)/placements/\(placementId)?key=\(publicAccessKey ?? "")"

        if let campaignId = campaign?.id {
            urlString += "&campaign_id=\(campaignId)"
        }

        if let customerId = customer?.id {
            urlString += "&customer_id=\(customerId)"
        }

        // Find the campaign page for this type by placementId or id
        let campaignPage = campaign?.campaignPages.first { page in
            page.placementId == placementId || page.id == placementId
        }

        // Use backgroundColor if available
        let backgroundColor = campaignPage?.screenProps?.backgroundColor?.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
        if let backgroundColor {
            urlString += "&bg=\(backgroundColor)"
        }

        // Append any custom query parameters
        if let queryParams, !queryParams.isEmpty {
            for (rawKey, rawValue) in queryParams {
                let key = rawKey.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? rawKey
                let value = rawValue.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? rawValue
                urlString += "&\(key)=\(value)"
            }
        }

        return URL(string: urlString)
    }

    /**
     Gets campaign checkpoints for a specific campaign.

     - Parameters:
        - campaignId: The unique identifier for the campaign.
     - Returns: An array of campaign checkpoints.
     */
    private func getCampaignCheckpoints(campaignId: String) async throws -> [CampaignCheckpoint] {
        guard let campaignCheckpointService else {
            throw URLError(.badURL)
        }

        return try await campaignCheckpointService.getCampaignCheckpoints(campaignId: campaignId)
    }

    /**
     Internal method to trigger checkpoint logic.
     */
    func triggerCheckpoint(
        checkpointName: String,
        options: CheckpointOptions,
        onClose: (() -> Void)?,
        onSuccess: ((Flock) -> Void)?,
        onInvalid: ((Flock) -> Void)?
    ) {
        guard let campaignCheckpoints else {
            Flock.logger.error("Campaign checkpoints not loaded. Make sure to call identify() first.")
            return
        }

        // Find the checkpoint by name
        guard let checkpoint = campaignCheckpoints.first(where: { $0.checkpointName == checkpointName }) else {
            Flock.logger.debug("Checkpoint with name '\(checkpointName)' not found.")
            return
        }

        // Add placement using the checkpoint's placementId
        guard let placementId = checkpoint.placementId else {
            Flock.logger.debug("Checkpoint '\(checkpointName)' does not have a placementId.")
            return
        }

        if options.navigate {
            // Navigate to the placement within existing webViewController
            navigate(placementId: placementId, queryParams: options.queryParams)
        } else {
            // Add new placement
            addPlacement(
                placementId: placementId,
                onClose: onClose,
                onSuccess: onSuccess,
                onInvalid: onInvalid,
                queryParams: options.queryParams
            )
        }
    }
}
