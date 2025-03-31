//
//  CustomUIPicker.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-29.
//

import SwiftUI

struct CustomPicker<T: Hashable>: View {
    let title: String
    let options: [T]  // Generic type allows flexibility (Strings, Enums, etc.)
    let displayText: (T) -> String // Closure to customize text display
    @Binding var selectedOption: T  // Binding to update selected value
    
    var body: some View {
        Picker(title, selection: $selectedOption) {
            ForEach(options, id: \.self) { option in
                Text(displayText(option)) // Works with Strings, Ints, Enums, etc.
                    .tag(option)
            }
        }
    }
}

