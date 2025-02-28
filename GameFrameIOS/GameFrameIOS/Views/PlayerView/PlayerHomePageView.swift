//
//  PlayerHomePageView.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-02-05.
//

import SwiftUI

struct PlayerHomePageView: View {
    var body: some View {

        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    Divider()
                    
                    // Scheduled Games Section
                    VStack(alignment: .leading, spacing: 10) {
                        NavigationLink(destination: PlayerAllScheduledGamesView()) {
                            Text("Scheduled Games")
                                .font(.headline)
                                .foregroundColor(.blue)
                            
                            Image(systemName: "chevron.right")
                        }
                        HStack {
                            
                            VStack {
                                Text("Game X vs Y").font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                Text("Team 1").font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                Text("mm/dd/yyyy").font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                Text("Starts in 50 minutes").font(.subheadline).bold().multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        Divider().background(content: { Color.gray.opacity(0.3) })
                        
                        HStack {
                            
                            VStack {
                                Text("Game A vs Y").font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                Text("Team 2").font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                Text("mm/dd/yyyy").font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                Text("Starts in 2 hours").font(.subheadline).bold().multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 2))
                    .padding(.horizontal).padding(.top)
                    
                    // Recent Footage Section
                    VStack(alignment: .leading, spacing: 10) {
                        NavigationLink(destination: PlayerAllRecentFootageView()) {
                            Text("Recent Footage")
                                .font(.headline)
                                .foregroundColor(.blue)
                            
                            Image(systemName: "chevron.right")
                        }
                            HStack {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 110, height: 60)
                                    .cornerRadius(10)
                                
                                VStack {
                                    Text("Game X vs Y").font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                    Text("Team 1").font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                    Text("mm/dd/yyyy").font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        Divider().background(content: { Color.gray.opacity(0.3) })
                        
                        HStack {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 110, height: 60)
                                .cornerRadius(10)
                            
                            VStack {
                                Text("Game A vs B").font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                Text("Team 2").font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                Text("mm/dd/yyyy").font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 2))
                    .padding(.horizontal).padding(.top)
                }
            }
            .background(Color(UIColor.white)).navigationTitle(Text("Home"))
        }
    
        }
    
}

#Preview {
    PlayerHomePageView()
}
