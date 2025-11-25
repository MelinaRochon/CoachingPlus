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
    
    let playerId: String
    
    @State private var selectedTab: Int = 3
    @Binding var showLandingPageView: Bool
    
    init(showLandingPageView: Binding<Bool>, playerId: String) {
        UITabBar.appearance().scrollEdgeAppearance = UITabBarAppearance()
        self._showLandingPageView = showLandingPageView
        self.playerId = playerId
    }
    
    var body: some View {
        ZStack {
            // main content for current tab
            currentTabView
                .edgesIgnoringSafeArea(.bottom)
            
            VStack {
                Spacer()
                
                // Custom Tab Bar
                HStack {
                    Spacer()
                    tabBarItem(image: "house",
                               filledImage: "house.fill",
                               label: "Home",
                               tabIndex: 0)
                    Spacer()
                    tabBarItem(image: "bell",
                               filledImage: "bell.fill",
                               label: "Activity",
                               tabIndex: 1)
                    Spacer()
                    tabBarItem(image: "tshirt",
                               filledImage: "tshirt.fill",
                               label: "Teams",
                               tabIndex: 2)
                    Spacer()
                    tabBarItem(image: "person",
                               filledImage: "person.fill",
                               label: "Profile",
                               tabIndex: 3)
                    Spacer()
                }
                .frame(height: 75)
                .background(Color.white)
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray),
                    alignment: .top
                )
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
    
    // MARK: - Tab content
    
    @ViewBuilder
    private var currentTabView: some View {
        switch selectedTab {
        case 0:
            PlayerHomePageView()
        case 1:
            PlayerNotificationView(playerId: playerId)
        case 2:
            PlayerTeamsView()
        case 3:
            PlayerProfileView(showLandingPageView: $showLandingPageView)
        default:
            PlayerHomePageView()
        }
    }
    
    // MARK: - Tab bar item
    
    private func tabBarItem(
        image: String,
        filledImage: String,
        label: String,
        tabIndex: Int
    ) -> some View {
        VStack {
            Image(systemName: selectedTab == tabIndex ? filledImage : image)
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(Color(.darkGray))
            
            Text(label)
                .font(.caption)
                .foregroundStyle(Color(.darkGray))
        }
        .padding()
        .onTapGesture {
            selectedTab = tabIndex
        }
    }
}

#Preview {
    PlayerMainTabView(showLandingPageView: .constant(false), playerId: "...")
}
