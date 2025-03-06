//
//  TestingView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-03.
//

import SwiftUI

struct TestingView: View {
    @State private var showCreateNewTeam = false // Switch to coach recording page
    //@State var team: Team;
    var body: some View {
        TabView {
            CoachHomePageView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            
            CoachNotificationView()
                .tabItem {
                    Image(systemName: "bell")
                    Text("Notifications")
                }
            
            CoachAllTeamsView(team: .init(name: "", sport: 0, icon: "", color: .blue, gender: 0, ageGrp: "", players: ""))
                .tabItem {
                    Image(systemName: "tshirt")
                    Text("Teams")
                }
            
            CoachProfileView(showLandingPageView: .constant(false))
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
        }
    }
    
    private func addTeam() {
        withAnimation {
            showCreateNewTeam.toggle()
        }
    }
}

#Preview {
    TestingView()

    //TestingView(team: .init(name: "", sport: 0, icon: "", color: .blue, gender: 0, ageGrp: "", players: ""))
}
