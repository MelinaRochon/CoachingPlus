//
//  CoachRecordingConfigView.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-03-13.
//

import Foundation

import SwiftUI

struct CoachRecordingConfigView: View {
    @State private var showCreateNewTeam = false // Switch to coach recording page
    //@State var team: Team;
    @State private var selectedTeam: String? = nil // Store selected team
    @State private var selectedRecordingType: String = "Video" // Default to Video
    @State private var useAppleWatch: Bool = false // Toggle for Apple Watch
    let teams = ["Team 1", "Team 2", "Team 3"]
    let recordingOptions = ["Video", "Audio Only"] // Recording choices
    var body: some View {
        NavigationView {
            VStack {
                //TestingView()
                Divider() // This adds a divider after the title
                
                List {
                    Section(header: Text("Select the Team Playing").font(.headline)) {
                                            ForEach(teams, id: \.self) { team in
                                                HStack {
                                                    Image(systemName: selectedTeam == team ? "checkmark.circle.fill" : "tshirt")
                                                        .foregroundColor(selectedTeam == team ? .blue : .gray)
                                                    Text(team)
                                                }
                                                .onTapGesture {
                                                    selectedTeam = team
                                                }
                                            }
                                        }
                    // **Recording Type Selection**
                                        Section(header: Text("Select Recording Type").font(.headline)) {
                                            Picker("Recording Type", selection: $selectedRecordingType) {
                                                ForEach(recordingOptions, id: \.self) { option in
                                                    Text(option)
                                                }
                                            }
                                            .pickerStyle(SegmentedPickerStyle()) // Makes it look like a toggle
                                        }
                    // **Apple Watch Toggle**
                                        Section(header: Text("Apple Watch").font(.headline)) {
                                            Toggle("Use Apple Watch for Recording", isOn: $useAppleWatch)
                                        }
                }
                .listStyle(PlainListStyle()) // Optional: Make the list style more simple
                Spacer()
                
                // **Start Recording Button**
                NavigationLink(
                    destination: CoachRecordingView(),
                    label: {
                                        Text("Start Recording")
                                            .font(.title2)
                                            .bold()
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(selectedTeam != nil ? Color.blue : Color.gray)
                                            .cornerRadius(12)
                                            .padding(.horizontal)
                                    }
                                )
                
            }
            .navigationTitle(Text("Start a recording"))
            
        }.fullScreenCover(isPresented: $showCreateNewTeam) {
            CoachCreateTeamView()
        }
    }
}

#Preview {
    CoachRecordingConfigView()
}
