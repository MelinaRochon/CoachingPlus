//
//  CustomMenuDropdown.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-11-24.
//

import SwiftUI

struct CustomMenuDropdown: View {
    var label: String
    var placeholder: String

    var isRequired: Bool = true

    var onSelect: () -> Void
    var options: [String]
    @Binding var selectedOption: String
        
    var foregroundColor: Color = .black
    var backgroundColor: Color = .white
    var disabled: Bool = false
    @FocusState private var isFocused: Bool

    private var fieldBackground: Color {
        disabled ? Color(.secondarySystemBackground) : backgroundColor
    }

    private var fieldStroke: Color {
        disabled ? Color(.secondarySystemBackground) : (isFocused ? .black : .gray)
    }
    
    private var fieldForegroundColor: Color {
        disabled ? Color(.systemGray) : foregroundColor
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 5) {
                if !label.isEmpty {
                    Text(label)
                        .font(.footnote)
                        .fontWeight(.semibold)
                    if isRequired {
                        Text("*")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                    }
                }
            }
            
            Button(action: onSelect) {
                HStack {
                    Text(placeholder)
                        .foregroundStyle(fieldForegroundColor)
                    Spacer()
                    
                    CustomPicker(
                        title: "",
                        options: options,
                        displayText: { $0 },
                        selectedOption: $selectedOption
                    )
                    .onChange(of: selectedOption) { _ in
                        // clear focus and hide keyboard when user picks an option
                        isFocused = false        // your @FocusState var in parent
                        hideKeyboard()
                    }
                }
                .font(.callout)
                .frame(height: 40)
                .padding(.leading, 15)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(fieldBackground)
                        .stroke(fieldStroke, lineWidth: 1)
                )
            }
            .foregroundColor(foregroundColor)
            .focused($isFocused)
            .disabled(disabled)
        }
        .padding(.top, 10)
    }
}

