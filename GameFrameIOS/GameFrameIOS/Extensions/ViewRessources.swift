//
//  ViewRessources.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-11-22.
//

import Foundation
import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}
