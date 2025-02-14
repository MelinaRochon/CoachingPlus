//
//  FilterTranscriptsListView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-13.
//

import SwiftUI

/*** This structure shows filtering options for the transcriptions showed */
struct FilterTranscriptsListView: View {
    @State private var sortByTime = true
    @State private var sortByPlayer = false
    private let playerNameTest = ["All", "Player 1", "Player 2", "Player 3"]
    private let positions = ["Off", "All", "Goalie", "Defender", "Midfielder", "Forward", "Striker"]
    @State private var positionSelected = "Off"
    @State private var playerSelected = "All"
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section {
                        HStack {
                            Toggle("Sort By Time", isOn: $sortByTime)
                        }
                        
                    }
                    
                    Section (header: HStack {
                        Text("Advanced") // Section header text
                    }) {
                        
                        HStack {
                            Picker("Sort By Positions", selection: $positionSelected) {
                                ForEach(positions, id: \.self) { position in
                                    Text(position)
                                }
                            }
                        }
                        
                        HStack {
                            Toggle("Sort By Player", isOn: $sortByPlayer)
                        }
                        
                        // Selecting players
                        if (sortByPlayer == true ) {
                            Picker("Select Player(s)", selection: $playerSelected) {
                                ForEach(playerNameTest, id: \.self) { name in
                                    Text(name)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Filter Options")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem {
                    Button (action: {
                        dismiss() // Close the filter options
                    }) {
                        Text("Done")
                    }
                }
            }
        }
    }
}

#Preview {
    FilterTranscriptsListView()
}
