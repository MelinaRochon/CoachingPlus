//
//  ColorResources.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-03-11.
//

import Foundation
import SwiftUI


/**This file contains an extension of the `Color` structure to provide additional
  functionality for handling color values using HEX strings. The extension allows
  easy conversion between `Color` and HEX string formats, making it convenient to
  work with colors in various formats across the application.

  ## Features:
  - `init?(hex: String)`: Initializes a `Color` instance from a HEX string (e.g., `#FF5733`).
  - `toHex()`: Converts a `Color` instance to its corresponding HEX string representation (e.g., `#FF5733`).

  This extension can be helpful when dealing with external color values or when you need
  to store or retrieve color values in HEX format.
 */
extension Color {
    
    /// Initializes a `Color` from a HEX string (e.g., `#FF5733`).
    /// This initializer allows creating a `Color` instance from a string that represents
    /// a HEX color code, providing an easy way to work with HEX color values in SwiftUI.
    ///
    /// - Parameter hex: The HEX color string, with or without the leading `#`.
    /// - Returns: A `Color` object corresponding to the provided HEX value, or `nil` if
    ///           the string cannot be parsed as a valid HEX color.
    ///
    /// Example usage:
    /// ```swift
    /// let color = Color(hex: "#FF5733")
    /// ```
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

    
    /// Converts `Color` to a HEX string (e.g., `#FF5733`).
        /// This function provides a way to convert a `Color` instance to its corresponding HEX
        /// string representation, useful when you need to work with HEX format colors in the app.
        ///
        /// - Returns: A HEX string representing the color in the format `#RRGGBB`, or `nil` if
        ///           the conversion fails.
        ///
        /// Example usage:
        /// ```swift
        /// let hexString = color.toHex()
        /// ```
    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components else { return nil }
        let red = Int((components[0] * 255).rounded())
        let green = Int((components[1] * 255).rounded())
        let blue = Int((components[2] * 255).rounded())

        return String(format: "#%02X%02X%02X", red, green, blue)
    }
}
