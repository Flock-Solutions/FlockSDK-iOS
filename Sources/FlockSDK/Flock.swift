import Foundation
import os
import SwiftUI
import UIKit

@available(iOS 14.0, *)
@MainActor
public class Flock: NSObject {
  public static let shared = Flock()

  private static let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier!,
    category: String(describing: Flock.self)
  )

  private(set) var isInitialized = false
  private var initializationCompletionHandlers: [(Bool) -> Void] = []

  /** Entities */
  private var publicAccessKey: String?
  private var environment: FlockEnvironment?
  private var campaign: Campaign?
  private var customer: Customer?

  /** Services */
  private var campaignService: CampaignService?
  private var customerService: CustomerService?

  override private init() {}

  public func initialize(
    publicAccessKey: String,
    environment: FlockEnvironment,
    overrideApiURL: String? = nil,
    completion: ((Bool) -> Void)? = nil
  ) {
    self.publicAccessKey = publicAccessKey
    self.environment = environment
    campaignService = CampaignService(publicAccessKey: publicAccessKey, baseURL: overrideApiURL)
    customerService = CustomerService(publicAccessKey: publicAccessKey, baseURL: overrideApiURL)

    // Fetch the live campaign from Flock
    Task { @MainActor in
      guard let campaignService = self.campaignService else { return }
      do {
        let campaign = try await campaignService.getLiveCampaign(environment: environment)
        self.campaign = campaign
        self.isInitialized = true
        completion?(true)
        self.initializationCompletionHandlers.forEach { $0(true) }
        self.initializationCompletionHandlers.removeAll()
      } catch {
        Flock.logger.error("Error during initialization: \(error)")
        completion?(false)
        self.initializationCompletionHandlers.forEach { $0(false) }
        self.initializationCompletionHandlers.removeAll()
      }

      // Pinging the server
      guard let campaign = self.campaign else { return }
      do {
        try await campaignService.ping(campaignId: campaign.id)
      } catch {
        Flock.logger.warning("Error pinging Flock: \(error)")
      }
    }
  }

  /**
   Identifies a customer to keep a record in Flock.

   - Parameters:
      - externalUserId: The unique identifier for the user in your system.
      - email: The customer's email address.
      - name: The customer's name (optional).
   */
  public func identify(externalUserId: String, email: String, name: String?) {
    guard isInitialized else {
      Flock.logger.debug("FlockSDK is not initialized. Queuing identify call...")
      // Queue the identify call to be called after initialization
      initializationCompletionHandlers.append { [weak self] success in
        guard success else {
          return
        }
        self?.identify(externalUserId: externalUserId, email: email, name: name)
      }
      return
    }

    Task {
      guard let campaign else { return }
      guard let customerService = self.customerService else { return }

      do {
        let identifyRequest = IdentifyRequest(
          externalUserId: externalUserId, email: email, name: name, campaignId: campaign.id
        )

        self.customer = try await customerService.identify(identifyRequest: identifyRequest)
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
   */
  public func openPage(
    type: String,
    onClose: (() -> Void)? = nil,
    onSuccess: (() -> Void)? = nil,
    onInvalid: (() -> Void)? = nil
  ) {
    guard isInitialized else {
      Flock.logger.debug("FlockSDK is not initialized. Queuing openPage call...")
      // Queue the openPage call to be called after initialization
      initializationCompletionHandlers.append { [weak self] success in
        guard success else {
          return
        }
        self?.openPage(type: type, onClose: onClose, onSuccess: onSuccess, onInvalid: onInvalid)
      }
      return
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
          topViewController.presentedViewController == nil
    else { return }

    webViewController.modalPresentationStyle = .pageSheet
    topViewController.present(webViewController, animated: true)
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
    var urlString = "\(appBaseURL)/pages/\(path)?key=\(publicAccessKey ?? "")"

    if let campaignId = campaign?.id {
      urlString += "&campaign_id=\(campaignId)"
    }

    if let customerId = customer?.id {
      urlString += "&customer_id=\(customerId)"
    }

    if let backgroundColor {
      urlString += "&bg=\(backgroundColor)"
    }

    if !query.isEmpty {
      urlString += "&\(query)"
    }

    return URL(string: urlString)
  }
}
