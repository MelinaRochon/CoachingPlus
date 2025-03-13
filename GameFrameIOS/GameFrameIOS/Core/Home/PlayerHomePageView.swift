//
//  PlayerHomePageView.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-02-05.
//

import SwiftUI

struct PlayerHomePageView: View {
    
    @StateObject private var viewModel = HomePageViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading) {
                        Divider()
                        
                        // Scheduled Games Section
                        if !viewModel.futureGames.isEmpty {
                            
                            VStack(alignment: .leading, spacing: 10) {
                                NavigationLink(destination: PlayerAllScheduledGamesView()) {
                                    Text("Scheduled Games")
                                        .font(.headline)
                                        .foregroundColor(.blue)
                                    
                                    Image(systemName: "chevron.right")
                                }
                                
                                // Loop through games and show a preview of the next 3 games
                                ForEach(viewModel.futureGames.prefix(3), id: \.game.gameId) { scheduledGame in
                                    HStack {
                                        VStack {
                                            Text(scheduledGame.game.title).font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                            
                                            Text(scheduledGame.team.name).font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                            Text(scheduledGame.game.startTime?.formatted(.dateTime.year().month().day().hour().minute()) ?? Date().formatted(.dateTime.year().month().day().hour().minute())).font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                            
                                            Divider().background(content: { Color.gray.opacity(0.3) })
                                        }
                                        
                                    }
                                }
                                
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 2))
                            .padding(.horizontal).padding(.top)
                            
                        }
                        if !viewModel.pastGames.isEmpty {
                            
                            // Recent Footage Section
                            VStack(alignment: .leading, spacing: 10) {
                                NavigationLink(destination: PlayerAllRecentFootageView()) {
                                    Text("Recent Footage")
                                        .font(.headline)
                                        .foregroundColor(.blue)
                                    
                                    Image(systemName: "chevron.right")
                                }
                                // Loop through games and show a preview of the past 3 games
                                ForEach(viewModel.pastGames.prefix(3), id: \.game.gameId) { pastGame in
                                    
                                    HStack {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(width: 110, height: 60)
                                            .cornerRadius(10)
                                        
                                        VStack {
                                            Text(pastGame.game.title).font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                            Text(pastGame.team.name).font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                            Text(pastGame.game.startTime?.formatted(.dateTime.year().month().day()) ?? Date().formatted(.dateTime.year().month().day())).font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                            
                                            Divider().background(content: { Color.gray.opacity(0.3) })
                                        }
                                    }
                                }
                                
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 2))
                            .padding(.horizontal).padding(.top)
                        }
                    }
                }
                
                // Show loader if the data is loading
                if viewModel.futureGames.isEmpty || viewModel.pastGames.isEmpty {
                    VStack() {
                        ProgressView("Loading games...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding()
                    }
                    .frame(maxHeight: .infinity) // Ensures that the loader is centered vertically
                }
            }
            .background(Color(UIColor.white)).navigationTitle(Text("Home"))
            .task {
                // on load
                do {
                    try await viewModel.loadGames()
                } catch {
                    print("Error needs to be handled. \(error)") // TO DO - Handle error
                }
            }
        }
    }
}

#Preview {
    PlayerHomePageView()
}
