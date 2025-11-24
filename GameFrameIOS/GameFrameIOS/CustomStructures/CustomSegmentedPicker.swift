//
//  CustomSegmentedPicker.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-11-22.
//

import SwiftUI

struct CustomSegmentedPicker: View {
    @Namespace private var animationNamespace  // ← Declare once here
    @Binding var selectedIndex: Int
    var options: [(title: String, icon: String?)] // Each option can have an optional SF Symbol icon
    var onSegmentTapped: ((Int) -> Void)?

    var body: some View {
        HStack(spacing: 0) {
            ForEach(options.indices, id: \.self) { index in
                Button(action: {
                    withAnimation(.easeInOut) {
                        onSegmentTapped?(index)
                        selectedIndex = index
                    }
                }) {
                    HStack(spacing: 5) {
                        if let iconName = options[index].icon {
                            Image(systemName: iconName)
                        }
                        Text(options[index].title)
                            .font(.callout)
                            .fontWeight(selectedIndex == index ? .bold : .regular)
                    }
                    .foregroundColor(selectedIndex == index ? .white : .black)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(
                        ZStack {
                            if selectedIndex == index {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.black)
                                    .matchedGeometryEffect(id: "segment", in: animationNamespace)
                            }
                        }
                    )
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
        )
        .padding()
    }
}


#Preview {
    @Previewable @State var selectedIndex = 0
    NavigationStack {
        CustomSegmentedPicker(
            selectedIndex: $selectedIndex,
            options: [
                (title: "My Teams", icon: "person.and.person.fill"),
                (title: "Team Requests", icon: "bell.badge"),
            ]
        )
    }
}
