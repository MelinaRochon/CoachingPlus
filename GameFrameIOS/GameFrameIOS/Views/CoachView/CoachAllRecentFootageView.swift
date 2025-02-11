//
//  CoachAllRecentFootageView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-11.
//

import SwiftUI

/** Shows all the recent footage saved. User can search for specific footages using the search bar */
struct CoachAllRecentFootageView: View {
    @State private var searchText: String = ""
    var body: some View {
        NavigationView {
            List  {
                Section {
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
                            Text("Game A vs B").font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                            Text("Team 2").font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                            Text("mm/dd/yyyy").font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    
                }
            }
            .listStyle(PlainListStyle()) // Optional: Make the list style more simple
                .background(Color.white) // Set background color to white for the List
        }.searchable(text: $searchText)
    }
}

#Preview {
    CoachAllRecentFootageView()
}
