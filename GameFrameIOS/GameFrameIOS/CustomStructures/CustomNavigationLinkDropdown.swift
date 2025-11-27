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


//
//  CustomNavigationLinkDropdown.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-11-22.
//

import SwiftUI

struct CustomText: View {
    var label: String
    var text: String
    
    var icon: String? = nil
    var iconColor: Color = .black

    var isRequired: Bool = true
        
    var foregroundColor: Color = .black
    var backgroundColor: Color = .white
    var disabled: Bool = false
    
    private var fieldBackground: Color {
        disabled ? Color(.secondarySystemBackground) : backgroundColor
    }

    private var fieldStroke: Color {
        disabled ? Color(.secondarySystemBackground) : .gray
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
                        .padding(.trailing, 5)
                }
                
                Text(text)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .foregroundStyle(fieldForegroundColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .font(.callout)
            .frame(height: 40)
            .padding(.horizontal)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(fieldBackground)
                    .stroke(fieldStroke, lineWidth: 1)
            )
            .disabled(disabled)
        }
        .padding(.top, 10)
        
    }
}
