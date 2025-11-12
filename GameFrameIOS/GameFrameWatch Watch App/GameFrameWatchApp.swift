//
//  GameFrameWatchApp.swift
//  GameFrameWatch Watch App
//
//  Created by Mélina Rochon on 2025-11-10.
//

import SwiftUI

@main
struct GameFrameWatch_Watch_AppApp: App {
    
    @StateObject private var watchConnectivityProvider = WatchConnectivityProvider()

    var body: some Scene {
        WindowGroup {
            if watchConnectivityProvider.isGameRecordingOn {
                ContentView()
                    .environmentObject(watchConnectivityProvider)
            } else {
                VStack {
                    ProgressView()
                    Text("Waiting for iPhone to start the game…")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                .alert("Connection Lost", isPresented: $watchConnectivityProvider.gameAbruptlyStoppedAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text("The iPhone app was closed. The game has been stopped.")
                }
            }
            
        }
    }
}
