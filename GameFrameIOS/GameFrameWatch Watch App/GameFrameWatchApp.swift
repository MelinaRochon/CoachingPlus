//
//  GameFrameWatchApp.swift
//  GameFrameWatch Watch App
//
//  Created by Mélina Rochon on 2025-11-25.
//

import SwiftUI

@main
struct GameFrameWatch_Watch_AppApp: App {
    @StateObject private var watchConnectivityProvider = WatchConnectivityProvider()
    
    var body: some Scene {
        WindowGroup {
            VStack {
                if watchConnectivityProvider.isGameRecordingOn {
                    ContentView()
                        .environmentObject(watchConnectivityProvider)
                } else {
                    VStack {
                        if watchConnectivityProvider.tryingToReconnectToPhoneAlert {
                            ProgressView()
                            Text("Reconnecting to iPhone…")
                                .font(.footnote)
                                .multilineTextAlignment(.center)
                                .padding()
                        } else {
                            ProgressView()
                            Text("Waiting for iPhone to start the game…")
                                .font(.footnote)
                                .multilineTextAlignment(.center)
                                .padding()
                        }
                    }
                    .alert("Connection Lost", isPresented: $watchConnectivityProvider.gameAbruptlyStoppedAlert) {
                        Button("OK", role: .cancel) { }
                    } message: {
                        Text("The GameFrame app on the iPhone was closed. The game has been stopped.")
                    }
                }
            }
            .onAppear {
                watchConnectivityProvider.requestCurrentGameState()
            }
        }
    }
}
