//
//  PlayerSpecificFootageView.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-02-05.
//

import SwiftUI

/**
 This view is responsible for displaying detailed footage and related information for a specific game within a team. It is designed for players to view their individual game footage, transcripts, and key moments.

 Key responsibilities:
 - Displays game details, including the title, team nickname, and start time.
 - Allows the user (player) to view the full game transcript and specific key moments from the game.
 - Displays a list of key moments and transcripts with related time codes and player involvement.
 - The user can tap on each key moment or transcript to navigate to more detailed views.
 - The player can view specific game details by navigating to a modal view that displays further information about the game.
 - The view model handles fetching all transcripts and key moments for the game and team, updating the UI accordingly.
 - If no transcripts or key moments are available, appropriate messages will be shown to inform the user.
 
 The view is structured to ensure the player can easily navigate between various sections, such as full game transcripts, key moments, and specific player recordings from the game.

 **Functions:**
 - `task`: Used to fetch the game’s start time, transcripts, and key moments as soon as the view appears. It populates the UI with relevant data, and if key moments or transcripts are found, it updates the state variables accordingly.
 - `isGameDetailsEnabled`: A state that controls the visibility of a sheet showing detailed game information when tapped.
 
 This view serves as a way for players to review detailed aspects of their gameplay, with options to view game summaries, key moments, and the full transcript of the game. It is built to be user-friendly, ensuring that players can easily access and review their performance based on the provided footage and annotations.

*/
struct PlayerSpecificFootageView: View {
    
    /// A view model for managing and fetching the transcripts and key moments of the game.
    @StateObject private var transcriptModel = TranscriptModel()

    /// Holds the start time of the game, used to calculate the timestamp for each key moment or transcript.
    @State private var gameStartTime: Date?

    /// A boolean flag that controls the visibility of the game details sheet.
    @State private var isGameDetailsEnabled: Bool = false

    /// A flag to track if key moments have been found for the game.
    @State private var keyMomentsFound: Bool = false

    /// A flag to track if transcripts have been found for the game.
    @State private var transcriptsFound: Bool = false

    /// The specific game for which the footage and related data is being displayed.
    @State var game: DBGame

    /// The team associated with the game and whose players' footage is being displayed.
    @State var team: DBTeam

    /// Holds the list of transcripts for the game.
    @State private var transcripts: [keyMomentTranscript]?

    /// Holds the list of key moments for the game.
    @State private var keyMoments: [keyMomentTranscript]?

    var body: some View {
//        NavigationView {
            ScrollView {
                VStack {
                    HStack(alignment: .top) {
                        VStack {
                            Text(game.title).font(.title2)
                            Text(team.teamNickname).font(.headline)
                            
                            if let gameStartTime = gameStartTime {
                                Text(gameStartTime, style: .date).font(.subheadline).foregroundStyle(.secondary)
                            }
                            Button {
                                isGameDetailsEnabled.toggle()
                            } label: {
                                Text("View Game Details").foregroundColor(Color.red).underline()
                            }
                            Divider()
                        }
                        
                    }
                    
                    // Watch Full Game
                    VStack(alignment: .leading, spacing: 0) {
                        NavigationLink(destination: PlayerFullGameTranscriptView()) {
                            Text("Full Game Transcript")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("Watch").foregroundColor(.gray)
                            Image(systemName: "chevron.right").foregroundColor(.gray)
                        }
                    }.padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 1))
                        .padding(.horizontal).padding(.top)
                        .disabled(true) // TODO: - Implement full game transcription in future release
                    
                    // Key moments
                    VStack(alignment: .leading, spacing: 10) {
                        NavigationLink(destination: PlayerAllKeyMomentsView(game: game, team: team, keyMoments: keyMoments)) {
                            Text("Key moments")
                                .font(.headline)
                                .foregroundStyle(keyMomentsFound ? .black : .secondary)
                            
                            Image(systemName: "chevron.right")
                                .foregroundStyle(keyMomentsFound ? .black : .secondary)
                            Spacer()
                            
                        }.padding(.bottom, 4).disabled(!keyMomentsFound)
                        
                        HStack (alignment: .top) {
                            if let keyMoments = keyMoments {
                                if !keyMoments.isEmpty {
                                    ForEach(keyMoments, id: \.id) { keyMoment in
                                        HStack(alignment: .top) {
                                            NavigationLink(destination: PlayerSpecificKeyMomentView(game: game, team: team, specificKeyMoment: keyMoment)) {
                                                Rectangle()
                                                    .fill(Color.gray.opacity(0.3))
                                                    .frame(width: 110, height: 60)
                                                    .cornerRadius(10)
                                                
                                                VStack {
                                                    HStack {
                                                        if let gameStartTime = gameStartTime {
                                                            let durationInSeconds = keyMoment.frameStart.timeIntervalSince(gameStartTime)
                                                            Text(formatDuration(durationInSeconds)).font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.bottom, 2).foregroundStyle(.black)
                                                            Spacer()
                                                            Image(systemName: "person.crop.circle").resizable().frame(width: 22, height: 22).foregroundStyle(.gray)
                                                        }
                                                    }
                                                    
                                                    Text(keyMoment.transcript).font(.caption).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).foregroundStyle(.black).lineLimit(3)
                                                }
                                            }
                                        }
                                    }
                                } else {
                                    // key moments empty
                                    Text("No key moments.").font(.caption).foregroundColor(.secondary)
                                }
                            }
                        }
                    }.padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 1))
                        .padding(.horizontal).padding(.top)
                    
                    // Transcript
                    VStack(alignment: .leading, spacing: 10) {
                        
                        NavigationLink(destination: PlayerAllTranscriptsView(game: game, team: team, transcripts: transcripts)) {
                            Text("Transcript")
                                .font(.headline)
                                .foregroundStyle(transcriptsFound ? .black : .secondary)
                            
                            Image(systemName: "chevron.right")
                                .foregroundStyle(transcriptsFound ? .black : .secondary)
                            Spacer()
                            
                        }.padding(.bottom, 4).disabled(!transcriptsFound)
                        if let transcripts = transcripts {
                            if !transcripts.isEmpty {
                                ForEach(transcripts, id: \.id) { recording in
                                    HStack(alignment: .center) {
                                        NavigationLink(destination: PlayerSpecificTranscriptView(game: game, team: team, transcript: recording)) {
                                            HStack(alignment: .center) {
                                                if let gameStartTime = gameStartTime {
                                                    let durationInSeconds = recording.frameStart.timeIntervalSince(gameStartTime)
                                                    Text(formatDuration(durationInSeconds)).bold().font(.headline).foregroundColor(Color.black)
                                                    Spacer()
                                                    Text("Transcript: \(recording.transcript)")
                                                        .font(.caption).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 2).lineLimit(3).padding(.top, 4).foregroundColor(Color.black)
                                                    
                                                    Image(systemName: "person.crop.circle").resizable().frame(width: 20, height: 20).foregroundColor(.gray)
                                                }
                                            }.tag(recording.id as Int)
                                        }.foregroundStyle(.black)
                                    }
                                }
                            } else {
                                // Transcripts empty
                                Text("No transcripts.").font(.caption).foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 1))
                    .padding(.horizontal).padding(.top)
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .task {
                do {
                    if let startTime = game.startTime {
                        gameStartTime = startTime
                    }
                    let (tmpTranscripts, tmpKeyMom) = try await transcriptModel.getAllTranscriptsAndKeyMoments(gameId: game.gameId, teamDocId: team.id)
                    
                    self.transcripts = tmpTranscripts
                    self.keyMoments = tmpKeyMom
                    
                    if let allTranscripts = transcripts {
                        if !allTranscripts.isEmpty {
                            transcriptsFound = true
                        }
                    }
                    
                    if let allKeyMoments = keyMoments {
                        if !allKeyMoments.isEmpty {
                            keyMomentsFound = true
                        }
                    }
                } catch {
                    print("Error when fetching specific footage info: \(error)")
                }
            }
            .sheet(isPresented: $isGameDetailsEnabled) {
                GameDetailsView(selectedGame: game, team: team, userType: "Player", dismissOnRemove: .constant(false))
            }
    }
}

#Preview {
    let team = DBTeam(id: "123", teamId: "team-123", name: "Testing Team", teamNickname: "TEST", sport: "Soccer", gender: "Mixed", ageGrp: "Senior", coaches: ["FbhFGYxkp1YIJ360vPVLZtUSW193"])
    
    let game = DBGame(gameId: "game1", title: "Ottawa vs Toronto", duration: 1020, scheduledTimeReminder: 10, timeBeforeFeedback: 15, timeAfterFeedback: 15, recordingReminder: true, teamId: "team-123")
    
    PlayerSpecificFootageView(game: game, team: team)
}
