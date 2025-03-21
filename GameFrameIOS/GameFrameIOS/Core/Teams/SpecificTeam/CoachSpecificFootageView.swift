//
//  CoachSpecificFootageView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-05.
//

import SwiftUI

struct CoachSpecificFootageView: View {
    
    @State var gameId: String // game Id
    @State var teamDocId: String // team document id
    
    @StateObject private var viewModel = SelectedGameModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                if let selectedGame = viewModel.selectedGame {
                    VStack {
                        HStack(alignment: .top) {
                            VStack {
                                Text(selectedGame.game.title).font(.title2).multilineTextAlignment(.center)
                                Text(selectedGame.team.name).font(.headline).foregroundStyle(.black.opacity(0.9))
                                if let startTime = selectedGame.game.startTime {
                                    Text(startTime, style: .date).font(.subheadline).foregroundStyle(.secondary)
                                }
                                if let location = selectedGame.game.location {
                                    Text(location).font(.subheadline).foregroundStyle(.secondary).italic(true).multilineTextAlignment(.center).padding(.bottom, 2).padding(.horizontal)
                                }
                                Divider()
                            }
                            
                        }
                        
                        // Watch Full Game
                        VStack(alignment: .leading, spacing: 0) {
                            NavigationLink(destination: CoachFullGameTranscriptView()) {
                                Text("Full Game Transcript")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                Spacer()
                                Text("Watch").foregroundColor(.gray)
                                Image(systemName: "chevron.right").foregroundColor(.gray)
                            }
                        }.padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 1))
                            .padding(.horizontal).padding(.top)
                        
                        // Key moments
                        VStack(alignment: .leading, spacing: 10) {
                            NavigationLink(destination: CoachAllKeyMomentsView(gameId: gameId, teamDocId: teamDocId)) {
                                Text("Key moments")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.black)
                                Spacer()
                                
                            }.padding(.bottom, 4)
                            
                            HStack (alignment: .top) {
                                NavigationLink(destination: CoachSpecificKeyMomentView(gameId: gameId, teamDocId: teamDocId)) {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 110, height: 60)
                                        .cornerRadius(10)
                                    
                                    VStack {
                                        HStack {
                                            Text("hh:mm:ss").font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.bottom, 2).foregroundStyle(.black)
                                            Spacer()
                                            Image(systemName: "person.crop.circle").resizable().frame(width: 22, height: 22).foregroundStyle(.gray)
                                        }
                                        
                                        Text("Transcript: \"Lorem ipsum dolor sit amet, consectetur adipiscing...\"").font(.caption).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).foregroundStyle(.black)
                                    }
                                }
                            }
                        }.padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 1))
                            .padding(.horizontal).padding(.top)
                        
                        // Transcript
                        VStack(alignment: .leading, spacing: 10) {
                            
                            NavigationLink(destination: CoachAllTranscriptsView(gameId: gameId, teamDocId: teamDocId)) {
                                Text("Transcript")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.black)
                                Spacer()
                                
                            }.padding(.bottom, 4)
                            
                            HStack (alignment: .top) {
                                NavigationLink(destination: CoachSpecificTranscriptView(gameId: gameId, teamDocId: teamDocId)) {
                                    VStack {
                                        HStack (alignment: .top) {
                                            Text("hh:mm:ss").font(.headline).multilineTextAlignment(.leading).padding(.bottom, 2)
                                            Spacer()
                                            Text("Transcript: \"Lorem ipsum dolor sit amet, consectetur adipiscing...\"").font(.caption).padding(.top, 4)
                                            Image(systemName: "person.circle").resizable().frame(width: 22, height: 22).foregroundStyle(.gray)
                                        }
                                        Divider().padding(.vertical, 2)
                                    }
                                }.foregroundStyle(.black)
                            }
                            HStack (alignment: .top) {
                                NavigationLink(destination: CoachSpecificTranscriptView(gameId: gameId, teamDocId: teamDocId)) {
                                    VStack {
                                        
                                        HStack (alignment: .top) {
                                            Text("hh:mm:ss").font(.headline).multilineTextAlignment(.leading).padding(.bottom, 2)
                                            Spacer()
                                            Text("Transcript: \"Lorem ipsum dolor sit amet, consectetur adipiscing...\"").font(.caption).padding(.top, 4)
                                            Image(systemName: "person.circle").resizable().frame(width: 22, height: 22).foregroundStyle(.gray)
                                        }
                                    }.foregroundStyle(.black)
                                }
                            }
                            
                        }.padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 1))
                            .padding(.horizontal).padding(.top)
                        
                    }
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .task {
                do {
                    try await viewModel.getSelectedGameInfo(gameId: gameId, teamDocId: teamDocId)
                } catch {
                    print("Error when fetching specific footage info: \(error)")
                }
            }
        }
    }
    
    
}

#Preview {
    CoachSpecificFootageView(gameId: "", teamDocId: "")
}
