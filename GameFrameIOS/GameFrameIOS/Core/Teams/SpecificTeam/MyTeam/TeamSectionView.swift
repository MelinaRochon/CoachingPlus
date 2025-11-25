//
//  TeamSectionView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-04-14.
//

import SwiftUI
import GameFrameIOSShared

/// A SwiftUI view that presents filtering and settings options for game and player visibility.
/// It allows toggling between upcoming and past games, and selecting a player filter option.
///
/// - Parameters:
///   - showUpcomingGames: A binding to a Boolean that controls whether upcoming games are shown.
///   - showRecentGames: A binding to a Boolean that controls whether past games are shown.
///   - showPlayers: A binding to an array of player filter options (e.g., "All Players").
///   - showPlayersIndex: A binding to the currently selected index in the `showPlayers` array.
struct TeamSectionView: View {
    @Binding var showUpcomingGames: Bool
    @Binding var showRecentGames: Bool
    @Binding var showPlayers: [String]
    @Binding var showPlayersIndex: Int
    @State var userType: UserType
    
    var body: some View {
        VStack(alignment: .center) {
            VStack(alignment: .center) {
                Text("Filtering Options")
                    .font(.title3)
                    .fontWeight(.semibold)
                Text("Filter games and players by date and status.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }
            Divider()
            VStack(alignment: .leading, spacing: 0) {
                CustomUIFields.customDivider("Footage Settings")
                    .padding(.top, 20)
                
                Button {
                    showRecentGames.toggle()
                } label: {
                    HStack {
                        Text("Show Past Games").foregroundStyle(.black)
                        Spacer()
                        
                        Image(systemName: showRecentGames ? "checkmark.circle.fill" : "circle").foregroundStyle(.red)
                    }
                    .contentShape(Rectangle())
                    .frame(height: 40)
                    .padding(.horizontal)
                }
                Divider().padding(.leading, 15)
                Button {
                    showUpcomingGames.toggle()
                } label: {
                    HStack {
                        Text("Show Upcoming Games").foregroundStyle(.black)
                        
                        Spacer()
                        Image(systemName: showUpcomingGames ? "checkmark.circle.fill" : "circle").foregroundStyle(.red)
                        
                    }
                    .contentShape(Rectangle())
                    .frame(height: 40)
                    .padding(.horizontal)
                }
                Divider().padding(.leading, 15)
                CustomUIFields.customDivider("Roster Settings")
                    .padding(.top, 30)
                CustomMenuDropdown(
                    label: "",
                    placeholder: "Show Players",
                    isRequired: false,
                    onSelect: {
                        hideKeyboard()
                    },
                    options: showPlayers,
                    selectedOption: $showPlayers[showPlayersIndex]
                )
            }
            .padding(.horizontal, 15)
            Spacer()
        }
    }
}
