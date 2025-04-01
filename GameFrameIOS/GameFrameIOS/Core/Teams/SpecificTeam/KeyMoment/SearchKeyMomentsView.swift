//
//  SearchKeyMomentsView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-13.
//

import SwiftUI

struct SearchKeyMomentsView: View {
    @State private var searchText: String = ""

//    @State var gameId: String // scheduled game id is passed when this view is called
//    @State var teamDocId: String // scheduled game id is passed when this view is called

    @StateObject private var transcriptModel = TranscriptViewModel()

    @State var game: DBGame
    @State var team: DBTeam

    @State var keyMoments: [keyMomentTranscript]?
    
    @State var userType: String

    var body: some View {
        NavigationView {
            VStack {
                List  {
                    if let keyMoments = keyMoments {
                        if !keyMoments.isEmpty{
                            ForEach(keyMoments, id: \.id) { keyMoment in
                                HStack(alignment: .top) {
                                    NavigationLink(destination: CoachSpecificKeyMomentView(game: game, team: team, specificKeyMoment: keyMoment)) {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(width: 110, height: 60)
                                            .cornerRadius(10)
                                        
                                        VStack {
                                            if let startTime = game.startTime {
                                                HStack {
                                                    let durationInSeconds = keyMoment.frameStart.timeIntervalSince(startTime)
                                                    Text(formatDuration(durationInSeconds)).bold().font(.headline)
                                                    Spacer()
                                                    Image(systemName: "person.crop.circle").resizable().frame(width: 22, height: 22).foregroundStyle(.gray)
                                                }
                                            }
                                            Text("Transcript: \(keyMoment.transcript)").font(.caption).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).lineLimit(3)
                                        }
                                    }
                                }
                            }
                        } else {
                            Text("No key moments found.").font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
                .listStyle(PlainListStyle()) // Optional: Make the list style more simple
                .navigationTitle("All Key Moments").navigationBarTitleDisplayMode(.inline)
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search key moments" )
            }
        }
//        .task {
//            do {
//                try await transcriptModel.getGameStartTime(gameId: gameId, teamDocId: teamDocId)
//                try await transcriptModel.loadFirstThreeTranscripts(gameId: gameId, teamDocId: teamDocId)
//            } catch {
//                print("Problem when loading the key moments: \(error)")
//            }
//        }
    }
}

#Preview {
    let team = DBTeam(id: "123", teamId: "team-123", name: "Testing Team", teamNickname: "TEST", sport: "Soccer", gender: "Mixed", ageGrp: "Senior", coaches: ["FbhFGYxkp1YIJ360vPVLZtUSW193"])
    
    let game = DBGame(gameId: "game1", title: "Ottawa vs Toronto", duration: 1020, scheduledTimeReminder: 10, timeBeforeFeedback: 15, timeAfterFeedback: 15, recordingReminder: true, teamId: "team-123")

    SearchKeyMomentsView(game: game, team: team, keyMoments: [], userType: "Player")
}
