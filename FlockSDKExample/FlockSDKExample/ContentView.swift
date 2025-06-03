//
//  ContentView.swift
//  FlockSDKExample
//
//  Created by Hoa Nguyen on 2024-10-02.
//

import FlockSDK
import SwiftUI

struct ContentView: View {
  var body: some View {
    VStack {
      Image(systemName: "globe")
        .imageScale(.large)
        .foregroundStyle(.tint)
      Text("Hello, world!")
      Button("Open Referral") {
        Flock.shared.openReferralView(style: .modal)
      }
    }
    .padding()
  }
}

#Preview {
  ContentView()
}
