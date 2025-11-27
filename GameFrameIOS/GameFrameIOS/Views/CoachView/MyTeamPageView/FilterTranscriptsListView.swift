//
//  FilterTranscriptsListView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-13.
//

import SwiftUI
import GameFrameIOSShared

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
        VStack(alignment: .center) {
            VStack(alignment: .center) {
                Text("Filtering Options")
                    .font(.title3)
                    .fontWeight(.semibold)
                Text("Filter feedback by player, position, or sort by time.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }
            Divider()
            VStack(alignment: .leading, spacing: 0) {
                Button {
                    sortByTime.toggle()
                } label: {
                    HStack {
                        Text("Sort By Time").foregroundStyle(.black)
                        Spacer()
                        
                        Image(systemName: sortByTime ? "checkmark.circle.fill" : "circle").foregroundStyle(.red)
                    }
                    .contentShape(Rectangle())
                    .frame(height: 40)
                    
                }
                
                if userType == .coach {
                    CustomUIFields.customDivider("Advanced")
                        .padding(.top, 20)
                    
                    Button {
                        sortByPlayer.toggle()
                    } label: {
                        HStack {
                            Text("Sort By Player").foregroundStyle(.black)
                            Spacer()
                            
                            Image(systemName: sortByPlayer ? "checkmark.circle.fill" : "circle").foregroundStyle(.red)
                        }
                        .contentShape(Rectangle())
                        .frame(height: 40)
                    }
                    
                    if sortByPlayer == true {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 5) {
                                Text("Players")
                                    .font(.footnote)
                                    .fontWeight(.semibold)
                            }
                            
                            Button(action: {
                                
                            }) {
                                HStack {
                                    Text("Select a Player")
                                        .foregroundStyle(.black)
                                    Spacer()
                                    // TODO: Make sure the players filter is working
                                    Picker("Select Players", selection: $playerSelectedIndex) {
                                        ForEach(playersNames.indices, id: \.self) { i in
                                            Text(self.playersNames[i].1).tag(i as Int)
                                        }
                                    }
                                }
                                .font(.callout)
                                .frame(height: 40)
                                .padding(.leading, 15)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(.gray, lineWidth: 1)
                                )
                            }
                            .foregroundColor(.black)
                        }
                        .padding(.top, 10)
                    }
                }
            }
            .padding(.top, 5)
            .padding(.horizontal, 15)
            
            Spacer()

        }
    }
}
