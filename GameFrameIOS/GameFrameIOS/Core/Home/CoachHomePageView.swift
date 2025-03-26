//
//  CoachHomePageView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-05.
//

import SwiftUI

struct CoachHomePageView: View {
    
    @StateObject private var viewModel = HomePageViewModel()
    @State private var recentGamesFound: Bool = false
    @State private var futureGamesFound: Bool = false
    var body: some View {
        NavigationStack {
//            ZStack {
                ScrollView {
                    VStack {
                        Divider()
                        
                        // Scheduled Games Section
                        
                        
                        VStack(alignment: .leading, spacing: 10) {
                            NavigationLink(destination: CoachAllScheduledGamesView()) {
                                Text("Scheduled Games")
                                    .font(.headline)
                                    .foregroundColor(futureGamesFound ? .black : .secondary)
                                
                                Image(systemName: "chevron.right").foregroundColor(futureGamesFound ? .black : .secondary)
                                Spacer()
                            }.padding(.bottom, 4).disabled(futureGamesFound == false)
                            HStack (alignment: .top) {
                                if !viewModel.futureGames.isEmpty {
                                    // Loop through games and show a preview of the next 3 games
                                    ForEach(viewModel.futureGames.prefix(3), id: \.game.gameId) { scheduledGame in
                                        HStack(alignment: .top) {
                                            NavigationLink(destination: SelectedScheduledGameView(gameId: scheduledGame.game.gameId, teamDocId: scheduledGame.team.id)) {
                                                VStack {
                                                    Text(scheduledGame.game.title).font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                                    
                                                    Text(scheduledGame.team.name).font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                                    Text(scheduledGame.game.startTime?.formatted(.dateTime.year().month().day().hour().minute()) ?? Date().formatted(.dateTime.year().month().day().hour().minute())).font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                                    
                                                    Divider().background(content: { Color.gray.opacity(0.3) })
                                                }
                                                
                                            }.foregroundColor(.black)
                                        }
                                    }
                                    
                                } else {
                                    Text("No scheduled game.").font(.caption).foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 1))
                        .padding(.horizontal).padding(.top)
                        
                        
                        
                        // Recent Footage Section
                        VStack(alignment: .leading, spacing: 10) {
                            NavigationLink(destination: CoachAllRecentFootageView()) {
                                HStack {
                                    Text("Recent Games")
                                        .font(.headline)
                                        .foregroundColor(recentGamesFound ? .black : .secondary)
                                    
                                    Image(systemName: "chevron.right").foregroundColor(recentGamesFound ? .black : .secondary)
                                    Spacer()
                                }
                            }.padding(.bottom, 4).disabled(recentGamesFound == false)
                            
                            if !viewModel.pastGames.isEmpty {
                                // Loop through games and show a preview of the past 3 games
                                ForEach(viewModel.pastGames.prefix(3), id: \.game.gameId) { pastGame in
                                    
                                    NavigationLink(destination: SelectedRecentGameView(gameId: pastGame.game.gameId, teamDocId: pastGame.team.id)) {
                                        HStack {
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(width: 110, height: 60)
                                                .cornerRadius(10)
                                            
                                            VStack {
                                                Text(pastGame.game.title).font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).foregroundStyle(.black)
                                                Text(pastGame.team.name).font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).foregroundStyle(.black)
                                                Text(pastGame.game.startTime?.formatted(.dateTime.year().month().day()) ?? Date().formatted(.dateTime.year().month().day())).font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).foregroundStyle(.black)
                                                //Divider().background(content: { Color.gray.opacity(0.3) })
                                            }
                                        }
                                    }
                                }
                            } else {
                                Text("No recent games.").font(.caption).foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 2))
                        .padding(.horizontal).padding(.top)
                    }
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .background(Color(UIColor.white)).navigationTitle(Text("Home"))
                .task {
                    // on load
                    do {
                        try await viewModel.loadGames()
                        if !viewModel.futureGames.isEmpty {
                            futureGamesFound = true
                        }
                        
                        if !viewModel.pastGames.isEmpty {
                            recentGamesFound = true
                        }
                        
                    } catch {
                        print("Error needs to be handled. \(error)") // TO DO - Handle error
                    }
                }
                // Show loader if the data is loading
//                if viewModel.futureGames.isEmpty && viewModel.pastGames.isEmpty {
//                    VStack() {
//                        ProgressView("Loading games...")
//                            .progressViewStyle(CircularProgressViewStyle())
//                            .padding()
//
//                    }
//                    .frame(maxHeight: .infinity) // Ensures that the loader is centered vertically
//                }
            }
            
        //}
    }
}

#Preview {
    CoachHomePageView()
}
