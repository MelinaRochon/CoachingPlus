//
//  SearchKeyMomentsView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-13.
//

import SwiftUI

struct SearchKeyMomentsView: View {
    @State private var searchText: String = ""

    @State var gameId: String // scheduled game id is passed when this view is called
    @State var teamDocId: String // scheduled game id is passed when this view is called

    var body: some View {
        NavigationView {
            VStack {
                List  {
                    ForEach(0..<5, id: \.self) { _ in
                        HStack (alignment: .top) {
                            NavigationLink(destination: CoachSpecificKeyMomentView(gameId: gameId, teamDocId: teamDocId)) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 110, height: 60)
                                    .cornerRadius(10)
                                
                                VStack {
                                    HStack {
                                        Text("hh:mm:ss").font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.bottom, 2)
                                        Spacer()
                                        Image(systemName: "person.crop.circle").resizable().frame(width: 22, height: 22).foregroundStyle(.gray)
                                    }
                                    
                                    Text("Transcript: \"Lorem ipsum dolor sit amet, consectetur adipiscing...\"").font(.caption).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                    
                                }
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle()) // Optional: Make the list style more simple
                .navigationTitle("All Key Moments").navigationBarTitleDisplayMode(.inline)
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search key moments" )
                //.scrollContentBackground(.hidden)
            }
        }
    }
}

#Preview {
    SearchKeyMomentsView(gameId: "", teamDocId: "")
}
