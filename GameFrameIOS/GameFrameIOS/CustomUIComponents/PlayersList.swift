//
//  PlayersList.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-04-14.
//

import SwiftUI

/// A SwiftUI view that displays a list of players with their names and current statuses.
/// If no players are found, a placeholder message is shown.
///
/// - Parameters:
///   - players: An array of `User_Status` objects representing players and their current status.
struct PlayersList: View {
    let players: [User_Status]
    let teamDocId: String
    
    var body: some View {
        // Iterate through the list of players
        ForEach (players, id: \.playerDocId) { player in
            // Navigation to specific player profile view
            NavigationLink(destination: CoachPlayerProfileView(playerDocId: player.playerDocId, userDocId: player.userDocId, teamDocId: teamDocId)) {
                HStack {
                    // Displaying player name and status
                    Text("\(player.firstName) \(player.lastName)")
                    Spacer()
                    Text(player.status).font(.footnote).foregroundStyle(.secondary).italic(true).padding(.trailing)
                }
            }
        }
    }
}

