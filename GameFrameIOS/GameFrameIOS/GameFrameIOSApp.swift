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
    @StateObject private var dependencies: DependencyContainer

    init(){
        UINavigationBar.appearance().tintColor = .red // ← this affects buttons
        
        // Optional: UITabBar tint if you're using tabs too
        UITabBar.appearance().tintColor = .red
        
        // Check for test mode
        let arguments = ProcessInfo.processInfo.arguments
        let useLocalRepositories = arguments.contains("DEBUG_NO_FIREBASE")
        print("use local repositories = \(useLocalRepositories)")
        if !useLocalRepositories {
            print("✅ FirebaseApp.configure() called")
            FirebaseApp.configure()
        } else {
            print("⚠️ Skipping Firebase configuration for UI testing.")
        }

        _dependencies = StateObject(wrappedValue: DependencyContainer(useLocalRepositories: useLocalRepositories))
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
                .environmentObject(dependencies)
        }
        .modelContainer(sharedModelContainer)
    }
}
