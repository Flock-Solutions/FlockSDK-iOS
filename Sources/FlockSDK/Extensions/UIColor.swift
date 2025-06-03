//
//  UIColor.swift
//  FlockSDK
//
//  Created by Hoa Nguyen on 2025-06-02.
//

import UIKit

extension UIColor {
  convenience init?(hex: String) {
    var cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")
    if cleaned.count == 6 {
      cleaned.append("FF")
    }
    guard cleaned.count == 8, let intVal = UInt64(cleaned, radix: 16) else { return nil }
    let red = CGFloat((intVal & 0xFF00_0000) >> 24) / 255.0
    let green = CGFloat((intVal & 0x00FF_0000) >> 16) / 255.0
    let blue = CGFloat((intVal & 0x0000_FF00) >> 8) / 255.0
    let alpha = CGFloat(intVal & 0x0000_00FF) / 255.0
    self.init(red: red, green: green, blue: blue, alpha: alpha)
  }
}
