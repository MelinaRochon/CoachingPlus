import SwiftUI

struct CoachMainTabView: View {
    @State private var showCoachRecordingConfig = false // Controls modal visibility
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
                case 0: CoachHomePageView()
                case 1: CoachNotificationView()
                case 2: CoachAllTeamsView()
                case 3: CoachProfileView(showLandingPageView: $showLandingPageView)
                default: CoachHomePageView()
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
                .frame(height: 80)
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
                        .foregroundColor(.gray)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: 20) // Floating effect
                }
                .offset(y: -20) // Position above the Tab Bar
            }
        }
        // Show CoachRecordingView when the plus button is clicked
        .fullScreenCover(isPresented: $showCoachRecordingConfig) {
            CoachRecordingConfigView()
        }
    }

    // Helper function for items (changes icon fill when selected)
    private func tabBarItem(image: String, filledImage: String, label: String, tabIndex: Int) -> some View {
        VStack {
            Image(systemName: selectedTab == tabIndex ? filledImage : image) // Change icon when selected
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(selectedTab == tabIndex ? Color(.darkGray) : Color(.darkGray))// Highlight selected tab
            Text(label)
                .font(.caption)
                .foregroundColor(selectedTab == tabIndex ? Color(.darkGray) : Color(.darkGray))
        }
        .padding()
        .onTapGesture {
            selectedTab = tabIndex // Change selected tab
        }
    }
}

#Preview {
    CoachMainTabView(showLandingPageView: .constant(false))
}



/**import SwiftUI
 
 struct CoachMainTabView: View {
     @State private var showCoachRecording = false // Controls modal visibility
     @State private var selectedTab: Int = 0 // Track selected tab
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
                 case 0: CoachHomePageView()
                 case 1: CoachNotificationView()
                 case 2: CoachAllTeamsView(team: .init(name: "", sport: 0, icon: "", color: .blue, gender: 0, ageGrp: "", players: ""))
                 case 3: CoachProfileView(profile: .constant(.init(
                     name: "John Doe",
                     dob: Date(),
                     email: "example@example.com",
                     phone: "613-555-5555",
                     country: "Canada",
                     timezone: "America/New_York"
                 )),  showLandingPageView: $showLandingPageView)
                 default: CoachHomePageView()
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
                 .frame(height: 80)
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
                     showCoachRecording.toggle() // Open CoachRecordingView
                 }) {
                     Image(systemName: "plus.circle.fill")
                         .resizable()
                         .frame(width: 80, height: 80) // Adjust size
                         .foregroundColor(.gray)
                         .background(Color.white)
                         .clipShape(Circle())
                         .shadow(radius: 20) // Floating effect
                 }
                 .offset(y: -20) // Position above the Tab Bar
             }
         }
         // Show CoachRecordingView when the plus button is clicked
         .fullScreenCover(isPresented: $showCoachRecording) {
             CoachRecordingView()
         }
     }

     // Helper function for items (changes icon fill when selected)
     private func tabBarItem(image: String, filledImage: String, label: String, tabIndex: Int) -> some View {
         VStack {
             Image(systemName: selectedTab == tabIndex ? filledImage : image) // Change icon when selected
                 .resizable()
                 .frame(width: 24, height: 24)
                 .foregroundColor(selectedTab == tabIndex ? Color(.darkGray) : Color(.darkGray))// Highlight selected tab
             Text(label)
                 .font(.caption)
                 .foregroundColor(selectedTab == tabIndex ? Color(.darkGray) : Color(.darkGray))
         }
         .padding()
         .onTapGesture {
             selectedTab = tabIndex // Change selected tab
         }
     }
 }

 #Preview {
     CoachMainTabView(showLandingPageView: .constant(false))
 }
*/
