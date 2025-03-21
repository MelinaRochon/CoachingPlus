//
//  CoachSpecificTranscriptView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-05.
//

import SwiftUI

struct CoachSpecificTranscriptView: View {
    
    @State var gameId: String // game Id
    @State var teamDocId: String // team document id
    
    @StateObject private var viewModel = TranscriptViewModel()

    var body: some View {
        ScrollView {
            if let game = viewModel.game {
                VStack {
                    VStack (alignment: .leading) {
                        HStack(spacing: 0) {
                            Text(game.title).font(.title2)
                            Spacer()
                            
                        }
                        HStack {
                            Text("Transcript #").font(.headline)
                            Spacer()
                        }.padding(.bottom, -2)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                if let team = viewModel.team {
                                    Text(team.name).font(.subheadline).foregroundStyle(.black.opacity(0.9))
                                }
                                if let startTime = game.startTime {
                                    Text(startTime.formatted(.dateTime.year().month().day().hour().minute())).font(.subheadline).foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                            // Edit Icon
                            Button(action: {}) {
                                Image(systemName: "pencil.and.outline")
                                    .foregroundColor(.blue) // Adjust color
                            }
                            // Share Icon
                            Button(action: {}) {
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundColor(.blue) // Adjust color
                            }
                        }
                    }.padding(.leading).padding(.trailing).padding(.top, 3)
                    
                    Divider().padding(.vertical, 2)
                    
                    // Transcription section
                    VStack(alignment: .leading) {
                        Text("hh:mm:ss").font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal).padding(.bottom, 2)
                        Text("\"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.\"").font(.caption).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal)
                    }.padding(.bottom, 10).padding(.top)
                    
                    
                    // Feedback for section
                    VStack(alignment: .leading) {
                        Text("Feedback For").font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.top, 10)
                        
                        HStack {
                            Image(systemName: "person.circle").resizable().frame(width: 22, height: 22).foregroundStyle(.gray).padding(.vertical, 5)
                            Text("John Doe")
                        }
                    }.padding(.horizontal)
                    
                    VStack {
                        Divider()
                        
                        // Comment section
                        CommentSectionView()
                        
                    }
                    .frame(maxHeight: .infinity, alignment: .bottom)
                }
            }
        }
        .task {
            do {
                try await viewModel.loadGameDetails(gameId: gameId, teamDocId: teamDocId)
            } catch {
                print("Error when fetching specific footage info: \(error)")
            }
        }
    }
}

#Preview {
    CoachSpecificTranscriptView(gameId: "", teamDocId: "")
}
