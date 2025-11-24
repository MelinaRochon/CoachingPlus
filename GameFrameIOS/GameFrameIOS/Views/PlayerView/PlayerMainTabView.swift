import SwiftUI

/** A SwiftUI view that serves as the main tab navigation for the player's section of the app.
  It displays a custom tab bar for easy navigation between different sections like:
  - Home
  - Activity (Notifications)
  - Teams
  - Profile

  The view supports:
  - Navigation between different tabs.
  - Custom tab bar with icons and labels, which dynamically changes based on the selected tab.
*/
struct PlayerMainTabView: View {
    @State private var selectedTab: Int = 3 // Track selected tab
    @Binding var showLandingPageView: Bool
    
    init(showLandingPageView: Binding<Bool>) {
        // Remove the default bottom shadow/line from the tab bar
        UITabBar.appearance().scrollEdgeAppearance = UITabBarAppearance()
        self._showLandingPageView = showLandingPageView
    }
    
    var body: some View {
        ZStack {
            Group {
                switch selectedTab {
                case 0: PlayerHomePageView()
                case 1: PlayerNotificationView()
                case 2: PlayerTeamsView()
                case 3: PlayerProfileView(showLandingPageView: $showLandingPageView)
                default: PlayerHomePageView()
                }
            }.edgesIgnoringSafeArea(.bottom) // Ensures full-screen usage
            
            
            VStack {
                
                Spacer()
                // Custom Tab Bar
                HStack {
                    Spacer()
                    tabBarItem(image: "house", filledImage: "house.fill", label: "Home", tabIndex: 0)
                    Spacer()
                    tabBarItem(image: "bell", filledImage: "bell.fill", label: "Activity", tabIndex: 1)
                    Spacer()
                    tabBarItem(image: "tshirt", filledImage: "tshirt.fill", label: "Teams", tabIndex: 2)
                    Spacer()
                    tabBarItem(image: "person", filledImage: "person.fill", label: "Profile", tabIndex: 3)
                    Spacer()
                }
                .frame(height: 75)
                .background(Color.white) // Tab bar background
                .overlay(
                    Rectangle()
                        .frame(height: 1) // Top border height
                        .foregroundColor(.gray), // Line color
                    alignment: .top // Places the line at the top
                )
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom) // tab stays at bottom

    }
    
    // Helper function for tab items (changes icon color and fill when selected)
    private func tabBarItem(image: String, filledImage: String, label: String, tabIndex: Int) -> some View {
        VStack {
            Image(systemName: selectedTab == tabIndex ? filledImage : image) // Change icon when selected
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(selectedTab == tabIndex ? Color(.darkGray) : Color(.darkGray)) // Active tab color
            Text(label)
                .font(.caption)
                .foregroundColor(selectedTab == tabIndex ? Color(.darkGray) : Color(.darkGray)) // Text color
        }
        .padding()
        .onTapGesture {
            selectedTab = tabIndex // Change selected tab
        }
    }
    
}

#Preview {
    PlayerMainTabView(showLandingPageView: .constant(false))
}
