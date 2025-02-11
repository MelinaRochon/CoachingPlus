import SwiftUI

struct PlayerMainTabView: View {
    @State private var selectedTab: Int = 0 // Track selected tab

    init() {
        // Remove the default bottom shadow/line from the tab bar
        UITabBar.appearance().scrollEdgeAppearance = UITabBarAppearance()
    }

    var body: some View {
        NavigationView {
            VStack {
                Group {
                    switch selectedTab {
                    case 0: PlayerHomePageView()
                    case 1: PlayerNotificationView()
                    case 2: PlayerAllTeamsView(team: .init(name: "", sport: 0, icon: "", color: .blue, gender: 0, ageGrp: "", players: ""))
                    case 3: PlayerProfileView(player: .init(name: "Mel Rochon", dob: Date(), jersey: 34, gender: 0, email: "mroch@uottawa.ca", profilePicture: nil, guardianName: "Jane Doe", guardianEmail: "jane@g.com", guardianPhone: "613-098-9999"))
                    default: PlayerHomePageView()
                    }
                }

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
                .frame(height: 80)
                .background(Color.white) // Tab bar background
                .overlay(
                    Rectangle()
                        .frame(height: 1) // Top border height
                        .foregroundColor(.gray), // Line color
                    alignment: .top // Places the line at the top
                )
            }
        }
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
    PlayerMainTabView()
}
