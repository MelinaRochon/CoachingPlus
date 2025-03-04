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
//    @StateObject private var authViewModel = AuthViewModel() // Manage user authentication state
    
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init(){
        FirebaseApp.configure()
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
//            if authViewModel.isLoggedIn {
//                            if authViewModel.userRole == .coach {
//                                CoachMainTabView(showLandingPageView: .constant(false))
//                            } else {
//                                PlayerMainTabView(showLandingPageView: .constant(false))
//                            }
//                        } else {
//                            LoginChoiceView(authViewModel: authViewModel) // Redirect to login if not authenticated
//                        }
            PlayerMainTabView(showLandingPageView: .constant(false))
            //ContentView()
                //.environment(\.font, Font.custom("WorkSans", size: 16))
//                .workSansFont(size: 16) // Apply work sans globally
            //NavigationStack {
            //AuthenticationView()
            /*RootView().environment(\.font, Font.custom("WorkSans", size: 16))*/ //.environment(\.font, Font.custom("WorkSans", size: 16))
                //.workSansFont(size: 16) // Apply work sans globally
            //}
        }
        .modelContainer(sharedModelContainer)
    }
}

/*class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
      print("Configured Firebase!")
    return true
  }
}*/
