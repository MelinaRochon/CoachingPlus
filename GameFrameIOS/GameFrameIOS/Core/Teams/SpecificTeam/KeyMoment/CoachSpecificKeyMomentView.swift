//
//  CoachSpecificKeyMomentView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-05.
//

import SwiftUI

/** This structure shows all details associated to a specific key moment, including the feedback given from the coach,
    the transcription, and comments conversations between the players concerned and the coach */
struct CoachSpecificKeyMomentView: View {
    @State private var progress: Double = 0.0
    @State private var comment: String = ""
        let totalDuration: Double = 180 // Example: 3 minutes (180 seconds)
    
    @State var gameId: String // game Id
    @State var teamDocId: String // team document id
    
    @StateObject private var viewModel = KeyMomentViewModel()

    
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
                            Text("Key moment #1").font(.headline)
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
                        }.padding(.bottom, -2)
                        HStack (spacing: 0){
                            VStack(alignment: .leading) {
                                if let team = viewModel.team {
                                    Text(team.name).font(.subheadline).foregroundStyle(.black.opacity(0.9))
                                }
                                if let startTime = game.startTime {
                                    Text(startTime.formatted(.dateTime.year().month().day().hour().minute())).font(.subheadline).foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                            VStack {
                                HStack {
                                    Text("Name").font(.subheadline).foregroundStyle(.secondary).padding(.top, 5)
                                    Image(systemName: "person.circle").resizable().frame(width: 22, height: 22).foregroundStyle(.gray).padding(.top, 5)
                                }
                            }
                        }
                        Spacer()
                    }.padding(.leading).padding(.trailing)
                    Divider()
                    
                    // Key moment Video Frame
                    VStack (alignment: .center){
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 340, height: 180)
                            .cornerRadius(10).padding(.bottom, 5)
                        
                        // Progress Slider
                        Slider(value: $progress, in: 0...totalDuration)
                            .tint(.gray) // Change color if needed
                            .frame(height: 20) // Adjust slider height
                        
                        // Time Labels (Start Time & Remaining Time)
                        HStack {
                            Text(formatTime(progress)) // Current time
                                .font(.caption)
                            
                            Spacer()
                            
                            Text("-\(formatTime(totalDuration - progress))") // Remaining time
                                .font(.caption)
                        }
                    }.padding()
                    
                    // Transcription section
                    VStack(alignment: .leading) {
                        Text("Transcription").font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal).padding(.bottom, 2)
                        Text("\"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.\"").font(.caption).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal)
                    }.padding(.bottom, 5)
                    
                    Divider()
                    
                    CommentSectionView()
                }
                
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .task {
            do {
                try await viewModel.loadGameDetails(gameId: gameId, teamDocId: teamDocId)
            } catch {
                print("Error when fetching specific footage info: \(error)")
            }
        }
        
    }
    
    // Custom TextField for Uniform Style
    private func commentTextField(_ placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .frame(height: 30)
            .padding(.horizontal)
            .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
            .foregroundColor(.black)
    }
    
    // Helper function to format time (e.g., 1:30)
    func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    CoachSpecificKeyMomentView(gameId: "", teamDocId: "")
}
