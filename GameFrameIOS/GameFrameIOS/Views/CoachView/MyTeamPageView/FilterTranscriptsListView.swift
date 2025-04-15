//
//  FilterTranscriptsListView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-13.
//

import SwiftUI

/**
 This structure displays filtering options for the transcriptions shown.
 It allows the user to sort by time, player, and position, and to select specific players for filtering.
 */
struct FilterTranscriptsListView: View {
    // State variables for controlling the sorting options
    private let playerNameTest = ["All", "Player 1", "Player 2", "Player 3"]  // Sample player names for selection
    private let positions = ["Off", "All", "Goalie", "Defender", "Midfielder", "Forward", "Striker"]  // Available positions to filter by
    @Binding var sortByTime: Bool // if on, then sort by duration, otherwise, by alphabethical order of the transcript
    @Binding var sortByPlayer: Bool
    @Binding var playersNames: [(String, String)]
    @Binding var playerSelectedIndex: Int
    @State var userType: UserType
    
    var body: some View {
        VStack {
            List {
                // First section: Sorting options (Time)
                Section {
                    // Toggle switch to sort by time
                    Toggle("Sort By Time", isOn: $sortByTime)
                }
                
                if userType == .coach {
                    // Second section: Advanced filter options
                    Section (header: HStack {
                        Text("Advanced") // Section header text
                    }) {
                        
                        // Toggle switch to enable or disable sorting by player
                        Toggle("Sort By Player", isOn: $sortByPlayer)
                        
                        // Show the player selection picker only if "Sort By Player" is enabled
                        if (sortByPlayer == true && userType == .coach) {
                            Picker("Select Players", selection: $playerSelectedIndex) {
                                ForEach(playersNames.indices, id: \.self) { i in
                                    Text(self.playersNames[i].1).tag(i as Int)
                                }
                            }
                            // TODO: Reimplement this so we can filter multiple players at once
                        }
                    }
                }
            }.scrollDisabled(true) // Disables scrolling for this list
        }
    }
}
