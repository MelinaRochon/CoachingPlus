//
//  CoachAllScheduledGamesView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-11.
//

import SwiftUI

/** Shows all the schedule games previously added by the coach. User can search for specific scheduled games using the search bar */
struct CoachAllScheduledGamesView: View {
    @State private var searchText: String = ""
    
    /*var filteredItems: [String] {
            if searchText.isEmpty {
                return items
            } else {
                return items.filter { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }*/
    
    var body: some View {
        NavigationView {
            List  {
                Section {
                    // Scheduled Games Section
                    HStack {
                        
                        VStack {
                            Text("Game X vs Y").font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                            Text("Team 1").font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                            Text("mm/dd/yyyy, hh:mm").font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                            Text("Scheduled for in 50 minutes").font(.subheadline).bold().multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    
                    HStack {
                        VStack {
                            Text("Game A vs Y").font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                            Text("Team 2").font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                            Text("mm/dd/yyyy, hh:mm").font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                            Text("Starts in 2 hours").font(.subheadline).bold().multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    
                    HStack {
                        VStack {
                            Text("Game A vs Y").font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                            Text("Team 2").font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                            Text("mm/dd/yyyy, hh:mm").font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                            Text("Starts in 1 week").font(.subheadline).bold().multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    
                    HStack {
                       VStack {
                            Text("Game A vs Y").font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                            Text("Team 2").font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                            Text("mm/dd/yyyy, hh:mm").font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                            Text("Starts in 1 week").font(.subheadline).bold().multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }.listStyle(PlainListStyle()) // Optional: Make the list style more simple
                    .background(Color.white) // Set background color to white for the List
        }.searchable(text: $searchText)
        
    }
}

#Preview {
    CoachAllScheduledGamesView()
}
