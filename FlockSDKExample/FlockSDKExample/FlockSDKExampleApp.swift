//
//  FlockSDKExampleApp.swift
//  FlockSDKExample
//
//  Created by Hoa Nguyen on 2024-10-02.
//

import SwiftUI
import FlockSDK

@main
struct FlockSDKExampleApp: App {
    init() {
        FlockSDK.configure (publicAccessKey: "6d004555db663cd2b4d2a9594fa80a1a", campaignId: "campaign_01j7kgkcn1eaqtg5vv9bac2xf9")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
