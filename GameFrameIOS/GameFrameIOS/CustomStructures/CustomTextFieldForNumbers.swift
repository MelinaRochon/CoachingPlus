//
//  CustomTextFieldForNumbers.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-11-22.
//

import SwiftUI

struct CustomTextFieldForNumbers: View {
    var label: String
    var placeholder: String = ""
    @Binding var value: Int
    var isRequired: Bool = true

    var icon: String? = nil
    var iconColor: Color = .gray
    
    var type: CustomTextFieldType = .number
    
    var foregroundColor: Color = .black
    var backgroundColor: Color = .white
    var disableAutocorrection: Bool = false
    var autoCapitalization: Bool = true
    var disabled: Bool = false
    @FocusState private var isFocused: Bool

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
            
            HStack {
                if let icon {
                    Image(systemName: icon)
                        .foregroundColor(iconColor)
                }
                TextField(placeholder, value: $value, format: .number)
                    .keyboardType(.numberPad)
                    .focused($isFocused)
                    .font(.callout)
            }
            .frame(height: 40)
            .padding(.horizontal)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundColor)
                    .stroke(isFocused ? Color.black : Color.gray, lineWidth: 1)
            )
            .foregroundColor(foregroundColor)
            .disabled(disabled)
            .autocorrectionDisabled(disableAutocorrection)
            .onSubmit {
                hideKeyboard()
            }
        }
        .padding(.top, 10)
    }
}
