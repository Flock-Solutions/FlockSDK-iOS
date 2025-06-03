//
//  UIColor.swift
//  FlockSDK
//
//  Created by Hoa Nguyen on 2025-06-02.
//

import UIKit

internal extension UIColor {
    convenience init?(hex: String) {
        var cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")
        if cleaned.count == 6 {
            cleaned.append("FF")
        }
        guard cleaned.count == 8, let intVal = UInt64(cleaned, radix: 16) else { return nil }
        let r = CGFloat((intVal & 0xFF000000) >> 24) / 255.0
        let g = CGFloat((intVal & 0x00FF0000) >> 16) / 255.0
        let b = CGFloat((intVal & 0x0000FF00) >> 8) / 255.0
        let a = CGFloat(intVal & 0x000000FF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
