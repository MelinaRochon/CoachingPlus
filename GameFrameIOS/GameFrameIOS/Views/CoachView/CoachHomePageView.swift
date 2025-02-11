//
//  CoachHomePageView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-05.
//

import SwiftUI

struct CoachHomePageView: View {
    var body: some View {

        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    Divider()
                    
                    // Scheduled Games Section
                    VStack(alignment: .leading, spacing: 10) {
                        NavigationLink(destination: CoachAllScheduledGamesView()) {
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
                        NavigationLink(destination: CoachAllRecentFootageView()) {
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
        
        /*NavigationView {
            VStack {
                
                Divider() // This adds a divider after the title
                
                //List {
                    Section(header: HStack {
                        HStack {
                            Text("Scheduled Game").bold() // Section header text
                            Spacer()
                            Button(action: {
                            
                            }) {
                                Text("View All").underline()
                                
                            }
                        }
                    }) {
                        
                        // Show scheduled games list
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
                        
                        HStack {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 110, height: 60)
                                .cornerRadius(10)
                            
                            VStack {
                                Text("Game X vs Y").font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                Text("Team 2").font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                Text("mm/dd/yyyy").font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }.frame(width: 350, height: 60)
                        
                        
                    }
                }
                .listStyle(PlainListStyle()) // Optional: Make the list style more simple
                .background(Color.white) // Set background color to white for the List
                
            }
            .background(Color.white)
            .navigationTitle(Text("Home"))
         */
        }
        
    
}

#Preview {
    CoachHomePageView()
}
