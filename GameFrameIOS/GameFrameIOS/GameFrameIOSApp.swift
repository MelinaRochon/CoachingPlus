//
//  GameFrameIOSApp.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-01-30.
//

import SwiftUI
import SwiftData
import FirebaseCore

@main
struct GameFrameIOSApp: App {
    init(){
        FirebaseApp.configure()
        
        UINavigationBar.appearance().tintColor = .red // ← this affects buttons
        
        // Optional: UITabBar tint if you're using tabs too
        UITabBar.appearance().tintColor = .red
    }
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(sharedModelContainer)
    }
}
