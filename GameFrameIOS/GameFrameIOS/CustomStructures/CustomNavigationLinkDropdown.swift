//
//  CustomNavigationLinkDropdown.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-11-22.
//

import SwiftUI

struct CustomNavigationLinkDropdown<Destination: View>: View {
    var label: String
    var placeholder: String
    let valueText: () -> String   // <-- CHANGE HERE
    var valueTextEmpty: String = "None"
    
    var icon: String? = nil
    var iconColor: Color = .black

    var isRequired: Bool = true
    @Binding var isActive: Bool

    let destination: Destination
    var onSelect: () -> Void
        
    var foregroundColor: Color = .black
    var backgroundColor: Color = .white
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
            
            // Navigation
            
            Button(action: onSelect) {
                HStack {
                    if let icon = icon {
                        Image(systemName: icon)
                            .foregroundStyle(iconColor)
                    }
                    Text(placeholder)
                        .foregroundColor(foregroundColor)
                    Spacer()
                    
                    let text = valueText()
                    if text.isEmpty {
                        Text(valueTextEmpty)
                            .foregroundStyle(.gray)
                    } else {
                        Text(text)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .foregroundStyle(foregroundColor)
                    }
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .font(.callout)
                .frame(height: 40)
                .padding(.horizontal)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(backgroundColor)
                        .stroke(isFocused ? Color.black : Color.gray, lineWidth: 1)
                )
                .disabled(disabled)
            }
            .focused($isFocused)
            
            NavigationLink(
                destination: destination,
                isActive: $isActive
            ) { EmptyView() }

        }
        .padding(.top, 10)
    }
}



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


struct CustomToggleField: View {
    var label: String
    var placeholder: String

    var isRequired: Bool = true

    var onSelect: () -> Void
    @Binding var toggleIsOn: Bool
        
    var icon: String? = nil
    var iconColor: Color = .black

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
            
                HStack {
                    if let icon = icon {
                        Image(systemName: icon)
                            .foregroundStyle(iconColor)
                    }
                    Toggle("Get Recording Reminder", isOn: $toggleIsOn)
                        .padding(.trailing, 15)
                }
                .font(.callout)
                .frame(height: 40)
                .padding(.leading, 15)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(fieldBackground)
                        .stroke(fieldStroke, lineWidth: 1)
                )
            
                .focused($isFocused)
                .disabled(disabled)
        }
        .padding(.top, 10)
    }
}
