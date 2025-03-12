//
//  ColorResources.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-03-11.
//

import Foundation
import SwiftUI

extension Color {
    /// Initializes a `Color` from a HEX string (e.g., `#FF5733`)
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0

        self.init(red: red, green: green, blue: blue)
    }

    /// Converts `Color` to a HEX string (e.g., `#FF5733`)
    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components else { return nil }
        let red = Int((components[0] * 255).rounded())
        let green = Int((components[1] * 255).rounded())
        let blue = Int((components[2] * 255).rounded())

        return String(format: "#%02X%02X%02X", red, green, blue)
    }
}
