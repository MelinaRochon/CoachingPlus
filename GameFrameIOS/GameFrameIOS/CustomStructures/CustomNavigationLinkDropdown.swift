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
    let valueText: String   // What should be displayed when something is selected

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
            NavigationLink(
                destination: destination,
                isActive: $isActive
            ) { EmptyView() }
            
            Button(action: onSelect) {
                HStack {
                    Text(placeholder)
                        .foregroundColor(foregroundColor)
                    Spacer()
                    
                    if valueText.isEmpty {
                        Text("None")
                            .foregroundStyle(.gray)
                    } else {
                        Text(valueText)
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
        }
        .padding(.top, 10)
    }
}

