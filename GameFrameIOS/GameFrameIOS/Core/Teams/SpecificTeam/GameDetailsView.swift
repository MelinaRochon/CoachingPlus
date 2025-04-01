//
//  GameDetailsView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-23.
//

import SwiftUI

struct GameDetailsView: View {
    @StateObject private var viewModel = SelectedGameModel()
//    @State var gameId: String // scheduled game id is passed when this view is called
//    @State var teamDocId: String // scheduled game id is passed when this view is called
    @Environment(\.dismiss) var dismiss // To go back to the Teams page, if needed
    
    @State private var hours: Int = 0;
    @State private var minutes: Int = 0;
    @State private var recordReminder: Bool = false;
    
    @State var selectedGame: DBGame
    @State var team: DBTeam

    @State var userType: String

    var body: some View {
        
        NavigationView {
            VStack {
//                if let selectedGame = selectedGame {
                    Text(selectedGame.title).font(.largeTitle).bold().multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.top, 5).padding(.bottom, 5).padding(.horizontal)
                    // View the game details
                    VStack {
                        Text("Game Details").multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).font(.headline)
                        
                        HStack {
                            Image(systemName: "person.2.fill").resizable().foregroundStyle(.red).aspectRatio(contentMode: .fit).frame(width: 18, height: 18)
                            Text(team.name).font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                            
                        }.multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.vertical, 4)
                        
                        HStack {
                            Image(systemName: "calendar.badge.clock").resizable().foregroundStyle(.red).aspectRatio(contentMode: .fit).frame(width: 18, height: 18)
                            Text(formatStartTime(selectedGame.startTime)).font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                        }.multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.vertical, 4)
                        
                        HStack (alignment: .center) {
                            if let location = selectedGame.location {
                                // On click -> go to apple maps to that specific location
                                Button {
                                    if location.contains("Search Nearby") {
                                        let newLocation = location.components(separatedBy: "Search Nearby")
                                        
                                        if let url = URL(string: "maps://?q=\(newLocation.first)") {
                                            if UIApplication.shared.canOpenURL(url) {
                                                UIApplication.shared.open(url)
                                            } else {
                                                print("Could not open Maps URL")
                                            }
                                        }
                                    } else {
                                        if let url = URL(string: "maps://?address=\(location)") {
                                            if UIApplication.shared.canOpenURL(url) {
                                                UIApplication.shared.open(url)
                                            } else {
                                                print("Could not open Maps URL")
                                            }
                                        }
                                    }
                                } label: {
                                    Image(systemName: "mappin.and.ellipse").resizable().foregroundStyle(.red).aspectRatio(contentMode: .fit).frame(width: 18, height: 18)
                                    Text(selectedGame.location ?? "None").font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).foregroundColor(.black)
                                }
                            }
                        }.multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.top, 4)
                        
                        HStack {
                            Image(systemName: "clock").resizable().foregroundStyle(.red).aspectRatio(contentMode: .fit).frame(width: 18, height: 18)
                            Text("\(hours) h \(minutes) m").font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                            
                            // TO DO - If is not a scheduled game and there was a video recording, show the actual game duration!
                        }.multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.vertical, 4)
                        
                        
                    }.padding(.horizontal)
                    
//                    if let userType = viewModel.userType {
                        if (userType == "Coach") {
                            Divider()
                            // View the game Settings
                            List {
                                Text("Game Settings").multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).font(.headline)
                                HStack {
                                    Text("Duration")
                                    Spacer()
                                    Text("\(hours) h \(minutes) m").foregroundStyle(.secondary)
                                }.multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                HStack {
                                    Text("Time Before Feedback")
                                    Spacer()
                                    Text("\(selectedGame.timeBeforeFeedback) seconds").foregroundStyle(.secondary)
                                }.multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                HStack {
                                    Text("Time After Feedback")
                                    Spacer()
                                    Text("\(selectedGame.timeAfterFeedback) seconds").foregroundStyle(.secondary)
                                }.multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                Toggle("Recording Reminder:", isOn: $recordReminder).disabled(true)
                                if recordReminder == true {
                                    // show alert
                                    HStack {
                                        Text("Alert")
                                        Spacer()
                                        Text("\(selectedGame.scheduledTimeReminder) seconds").foregroundStyle(.secondary)
                                    }.multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                }
                                
                            }.listStyle(.plain)
                        }
//                    }
                    Spacer()
//                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done").font(.subheadline)
                    }
                }
            }
        }
        .task {
            do {
//                try await viewModel.getSelectedGameInfo(gameId: gameId, teamDocId: teamDocId)
//                try await viewModel.getUserType()
//                if let selectedGame = viewModel.selectedGame {
                    // Get the duration to be shown
                    let (dhours, dminutes) = convertSecondsToHoursMinutes(seconds: selectedGame.duration)
                    self.hours = dhours
                    self.minutes = dminutes
                self.recordReminder = selectedGame.recordingReminder
//                }
                
                
            } catch {
                print("ERROR. \(error)")
            }
        }
    }
}

#Preview {
    let team = DBTeam(id: "123", teamId: "team-123", name: "Testing Team", teamNickname: "TEST", sport: "Soccer", gender: "Mixed", ageGrp: "Senior", coaches: ["FbhFGYxkp1YIJ360vPVLZtUSW193"])
    
    let game = DBGame(gameId: "game1", title: "Ottawa vs Toronto", duration: 1020, scheduledTimeReminder: 10, timeBeforeFeedback: 15, timeAfterFeedback: 15, recordingReminder: true, teamId: "team-123")


    GameDetailsView(selectedGame: game, team: team, userType: "Player")
}
