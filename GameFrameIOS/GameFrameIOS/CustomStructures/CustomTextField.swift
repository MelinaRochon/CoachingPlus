//
//  CustomTextField.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-11-20.
//

import SwiftUI

enum CustomTextFieldType {
    case normal
    case email
    case phone
    case number
    case secure
}

struct CustomTextField: View {
    var label: String
    var placeholder: String = ""
    @Binding var text: String
    var isRequired: Bool = true

    var icon: String? = nil
    var iconColor: Color = .gray
    
    var type: CustomTextFieldType = .normal
    
    var foregroundColor: Color = .black
    var backgroundColor: Color = .white
    var disableAutocorrection: Bool = false
    var autoCapitalization: Bool = true
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
            
            HStack {
                if let icon {
                    Image(systemName: icon)
                        .foregroundColor(iconColor)
                }
                inputField
                    .focused($isFocused)
                    .font(.callout)
                    .foregroundStyle(fieldForegroundColor)
                    .textInputAutocapitalization(autoCapitalization ? .sentences : .never )
            }
            .frame(height: 40)
            .padding(.horizontal)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(fieldBackground)
                    .stroke(fieldStroke, lineWidth: 1)
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
    
    @ViewBuilder
    private var inputField: some View {
        switch type {
        case .secure:
            SecureField(placeholder, text: $text)
                .keyboardType(.default)
            
        case .email:
            TextField(placeholder, text: $text)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
            
        case .phone:
            TextField(placeholder, text: $text)
                .keyboardType(.phonePad)
                .onChange(of: text) { newVal in
                    text = formatPhoneNumber(newVal)
                }
            
        case .number:
            TextField(placeholder, text: $text)
                .keyboardType(.numberPad)
            
        case .normal:
            TextField(placeholder, text: $text)
                .keyboardType(.default)
        }
    }
}
