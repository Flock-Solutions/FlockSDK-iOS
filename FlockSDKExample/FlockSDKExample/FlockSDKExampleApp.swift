//
//  FlockSDKExampleApp.swift
//  FlockSDKExample
//
//  Created by Hoa Nguyen on 2024-10-02.
//

import FlockSDK
import SwiftUI

@main
struct FlockSDKExampleApp: App {
  init() {
    Flock.configure(publicAccessKey: "6d004555db663cd2b4d2a9594fa80a1a", campaignId: "campaign_01j7kgkcn1eaqtg5vv9bac2xf9", overrideApiURL: "http://localhost:3000")

    Flock.shared.identify(externalUserId: "user_01j7kgkcn1eaqtg5vv9bac2xf9", email: "user@example.com", name: "User Name")
  }

  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}
