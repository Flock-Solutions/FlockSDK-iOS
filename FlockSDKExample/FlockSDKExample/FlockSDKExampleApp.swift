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
    Flock.shared.initialize(publicAccessKey: "pk_ba3b841f41c4b26cc34fa6aebf660efb", environment: .test)
    Flock.shared.identify(externalUserId: "user_01j7kgkcn1eaqtg5vv9bac2xf9", email: "user@example.com", name: "User Name")
  }

  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}
