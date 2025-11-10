//
//  OrientationViewModifier.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-11-10.
//

import SwiftUI

struct OrientationViewModifier: ViewModifier {
    @State private var isLandscape = UIDevice.current.orientation.isLandscape

    func body(content: Content) -> some View {
        ZStack {
            content
                .onAppear(perform: updateOrientation)
                .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                    updateOrientation()
                }
            
            if !isLandscape {
                // Full-screen alert overlay
                Color.black.opacity(0.8)
                    .ignoresSafeArea()
                    .overlay(
                        VStack(spacing: 20) {
                            Image(systemName: "rectangle.landscape.rotate")
                                .font(.system(size: 80))
                                .foregroundColor(.white)
                                .symbolEffect(.bounce, options: .repeat(2)) // fun little animation (iOS 17+)
                            Text("Please rotate your device")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                            Text("Landscape mode is required to continue")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                        }
                            .multilineTextAlignment(.center)
                            .padding()
                    )
                    .transition(.opacity)
                    .animation(.easeInOut, value: isLandscape)
            }
        }
    }

    private func updateOrientation() {
        withAnimation {
            isLandscape = UIDevice.current.orientation.isValidInterfaceOrientation
            ? UIDevice.current.orientation.isLandscape
            : UIScreen.main.bounds.width > UIScreen.main.bounds.height
        }
    }
}

