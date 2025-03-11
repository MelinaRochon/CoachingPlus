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
    @StateObject private var viewModel = RecentFootageViewModel()
    
    var body: some View {
        NavigationView {
            List  {
                Section {
                    ForEach(viewModel.pastGames, id: \.game.gameId) { pastGame in
                        HStack {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 110, height: 60)
                                .cornerRadius(10)
                            
                            VStack {
                                Text(pastGame.game.title).font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                Text(pastGame.team.name).font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                Text(pastGame.game.startTime?.formatted(.dateTime.year().month().day().hour().minute()) ?? Date().formatted(.dateTime.year().month().day().hour().minute())).font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                            
                    }
                }
            }
            .listStyle(PlainListStyle()) // Optional: Make the list style more simple
                .background(Color.white) // Set background color to white for the List
        }
        .searchable(text: $searchText)
        .task {
            do {
                try await viewModel.loadAllRecentGames()
            } catch {
                print("Error needs to be handled. \(error)") // TO DO - Handle error
            }
        }
    }
}

#Preview {
    CoachAllRecentFootageView()
}
