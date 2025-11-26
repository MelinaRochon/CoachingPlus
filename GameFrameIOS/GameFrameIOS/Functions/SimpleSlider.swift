//
//  SimpleSlider.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-11-25.
//

import SwiftUI

struct SimpleSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    var width: CGFloat = 300
    var onEditingChanged: ((Bool) -> Void)? = nil
    var thumbPadding: CGFloat = 5

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Track
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 4)
                    .cornerRadius(5)
                
                // Thumb
                Circle()
                    .fill(Color.white)
                    .frame(width: 20, height: 20)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    .offset(x: thumbOffset(for: value, geoWidth: geo.size.width))
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                onEditingChanged?(true)
                                let trackWidth = geo.size.width
                                let ratio = gesture.location.x / trackWidth
                                let newValue = range.lowerBound
                                    + Double(ratio) * (range.upperBound - range.lowerBound)
                                
                                value = min(max(newValue, range.lowerBound), range.upperBound)
                            }
                            .onEnded { _ in
                                onEditingChanged?(false)
                            }
                    )
            }
        }
        .frame(height: 20)
    }
    
    private func thumbOffset(for value: Double, geoWidth: CGFloat) -> CGFloat {
        let trackWidth = geoWidth - 2 * thumbPadding
        let ratio = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
        return thumbPadding + CGFloat(ratio) * trackWidth - 10
    }
}


#Preview {
    SimpleSliderPreview()
}

struct SimpleSliderPreview: View {
    @State private var progress: Double = 5
    let total: Double = 60

    var body: some View {
        VStack(spacing: 20) {
            Text("Progress: \(progress, specifier: "%.1f")s")
                .font(.headline)
            
            SimpleSlider(value: $progress, range: 0...total)
                .padding(.horizontal, 25)
                .padding(.vertical)
                .border(Color.gray, width: 3)
        }
        .frame(width: 300)
    }
}
