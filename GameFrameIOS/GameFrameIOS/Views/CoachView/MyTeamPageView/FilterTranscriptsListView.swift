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
    @State private var sortByTime = true  // Sort by time toggle state
    @State private var sortByPlayer = false  // Sort by player toggle state
    private let playerNameTest = ["All", "Player 1", "Player 2", "Player 3"]  // Sample player names for selection
    private let positions = ["Off", "All", "Goalie", "Defender", "Midfielder", "Forward", "Striker"]  // Available positions to filter by
    @State private var positionSelected = "Off"  // Default selected position
    @State private var playerSelected = "All"  // Default selected player for filtering

    var body: some View {
        VStack {
            List {
                // First section: Sorting options (Time)
                Section {
                    // Toggle switch to sort by time
                    Toggle("Sort By Time", isOn: $sortByTime)
                }
                
                // Second section: Advanced filter options
                Section (header: HStack {
                    Text("Advanced") // Section header text
                }) {
                    // Picker for selecting positions to filter by
                    CustomPicker(title: "Sort By Positions", options: positions, displayText: { $0 }, selectedOption: $positionSelected)
                    
                    // Toggle switch to enable or disable sorting by player
                    Toggle("Sort By Player", isOn: $sortByPlayer)
                    
                    
                    // Show the player selection picker only if "Sort By Player" is enabled
                    if (sortByPlayer == true ) {
                        CustomPicker(title: "Select Player", options: playerNameTest, displayText: { $0 }, selectedOption: $playerSelected)
                        // TODO: Reimplement this so we can filter multiple players at once
                    }
                }
            }
        }
    }
}

#Preview {
    FilterTranscriptsListView()
}
