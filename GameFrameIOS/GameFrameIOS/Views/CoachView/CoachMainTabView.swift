import SwiftUI


/** A SwiftUI view that serves as the main tab navigation for the coach's section of the app.
  It displays a custom tab bar for easy navigation between different sections like:
  - Home
  - Activity (Notifications)
  - Teams
  - Profile

  Additionally, it includes a floating "plus" button that, when tapped, opens the
  CoachRecordingConfigView for the coach to configure or start a recording session.

  The view supports:
  - Navigation between different tabs.
  - Full-screen presentation of the CoachRecordingConfigView when the plus button is tapped.
  - Custom tab bar with icons and labels, which dynamically changes based on the selected tab.
*/
struct CoachMainTabView: View {
    
    let coachId: String
    @EnvironmentObject private var dependencies: DependencyContainer
    
    @State private var showCoachRecordingConfig = false // Controls modal visibility
    @State private var selectedTab: Int = 3 // Track selected tab
    @Binding var showLandingPageView: Bool
    
    let homeView = CoachHomePageView()
    let notificationView: CoachNotificationView
    let teamsView = CoachAllTeamsView()
    let profileView: CoachProfileView
    
    init(showLandingPageView: Binding<Bool>, coachId: String) {
        // Remove the default bottom shadow/line from the tab bar
        UITabBar.appearance().scrollEdgeAppearance = UITabBarAppearance()
        self._showLandingPageView = showLandingPageView
        self.coachId = coachId
        
        self.notificationView = CoachNotificationView(coachId: coachId)
        self.profileView = CoachProfileView(showLandingPageView: showLandingPageView)

    }
    
    var body: some View {
        ZStack {
            Group {
//                switch selectedTab {
//                case 0: CoachHomePageView()
//                case 1: CoachNotificationView(coachId: coachId)
//                case 2: CoachAllTeamsView()
//                case 3: CoachProfileView(showLandingPageView: $showLandingPageView)
//                default: CoachHomePageView()
//                }
                switch selectedTab {
                        case 0: AnyView(homeView)
                        case 1: AnyView(notificationView)
                        case 2: AnyView(teamsView)
                        case 3: AnyView(profileView)
                        default: AnyView(homeView)
                        }
            }
            .edgesIgnoringSafeArea(.bottom) // Ensures full-screen usage
            
            VStack {
                Spacer()
                
                // Custom Tab Bar with Top Border
                HStack {
                    Spacer()
                    tabBarItem(image: "house", filledImage: "house.fill", label: "Home", tabIndex: 0)
                    Spacer()
                    tabBarItem(image: "bell", filledImage: "bell.fill", label: "Activity", tabIndex: 1)
                    Spacer().frame(width: 80) // Space for floating button
                    tabBarItem(image: "tshirt", filledImage: "tshirt.fill", label: "Teams", tabIndex: 2)
                    Spacer()
                    tabBarItem(image: "person", filledImage: "person.fill", label: "Profile", tabIndex: 3)
                    Spacer()
                }
                .frame(height: 75)
                .background(Color.white) // Tab bar background
                .overlay(
                    Rectangle()
                        .frame(height: 1) // Height of the top border
                        .foregroundColor(.gray), // Line color
                    alignment: .top // Places the line at the top
                )
            }
            
            // Plus Button - Centered + Floating
            VStack {
                Spacer()
                Button(action: {
                    showCoachRecordingConfig.toggle() // Open CoachRecordingConfigView
                }) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 80, height: 80) // Adjust size
                        .foregroundColor(.gray) // .red
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: 20) // Floating effect
                }
                .offset(y: -20) // Position above the Tab Bar
            }
        }
        // Show CoachRecordingView when the plus button is clicked
        .fullScreenCover(isPresented: $showCoachRecordingConfig) {
            CoachRecordingConfigView(showLandingPageView: $showLandingPageView)
        }.navigationBarBackButtonHidden(true) // Hides the back button
            .ignoresSafeArea(.keyboard, edges: .bottom) // tab stays at bottom
            .task {
                    await preloadUnreadNotificationsOnLaunch()
                }
    }
    
    // Helper function for items (changes icon fill when selected)
    private func tabBarItem(image: String, filledImage: String, label: String, tabIndex: Int) -> some View {
        Button(action: {
            selectedTab = tabIndex
        }) {
            VStack {
                Image(systemName: selectedTab == tabIndex ? filledImage : image) // Change icon when selected
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(Color(.darkGray))
//                    .foregroundColor(selectedTab == tabIndex ? Color(.darkGray) : Color(.darkGray))// Highlight selected tab
                
                    .overlay(alignment: .topTrailing) {
                        if tabIndex == 1 && dependencies.hasUnreadNotifications {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 8, height: 8)
                                .offset(x: 4, y: -4)
                        }
                    }
                
                Text(label)
                    .font(.caption)
                    .foregroundColor(Color(.darkGray))
//                    .foregroundColor(selectedTab == tabIndex ? Color(.darkGray) : Color(.darkGray))
            }
            .padding()
        }
        .accessibilityIdentifier("navBar.tab.\(label.lowercased())")
    }
    
    private func preloadUnreadNotificationsOnLaunch() async {
        do {
            // Map from coachId (auth uid) to domain user doc id
            guard let user = try await dependencies.userManager.getUser(userId: coachId) else {
                print("⚠️ Could not resolve user for coachId \(coachId)")
                return
            }
            let userDocId = user.id
            print("🔍 Preloading notifications for userDocId: \(userDocId)")

            let recent = try await dependencies.notificationManager
                .getNotificationsForUser(userDocId: userDocId, limit: 20)

            await MainActor.run {
                dependencies.hasUnreadNotifications = recent.contains { !$0.isRead }
                print("🔴 hasUnreadNotifications on launch = \(dependencies.hasUnreadNotifications)")
            }
        } catch {
            print("❌ Failed to preload notifications: \(error)")
        }
    }

}

#Preview {
    CoachMainTabView(showLandingPageView: .constant(false), coachId: "...")
}
