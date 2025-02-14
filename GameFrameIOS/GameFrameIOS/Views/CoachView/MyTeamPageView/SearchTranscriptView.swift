//
//  SearchTranscriptView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-13.
//

import SwiftUI

/** Shows all transcripts saved using a list */
struct SearchTranscriptView: View {
    @State private var searchText: String = ""
    var body: some View {
        NavigationView {
            
            VStack {
                List {
                    ForEach(0..<10, id: \.self) { _ in
                        HStack(alignment: .top) {
                            NavigationLink(destination: CoachSpecificTranscriptView()) {
                                VStack {
                                    HStack(alignment: .top) {
                                        Text("hh:mm:ss")
                                            .font(.headline)
                                        Spacer()
                                        Text("Transcript: \"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.\"")
                                            .font(.caption)
                                            .padding(.top, 4)
                                        Image(systemName: "person.circle")
                                            .resizable()
                                            .frame(width: 22, height: 22)
                                            .foregroundStyle(.gray)
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())// Simplifies list style
                .navigationTitle("All Transcripts").navigationBarTitleDisplayMode(.inline)
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search transcripts" )
                .scrollContentBackground(.hidden)
            }
        }
    }
}

#Preview {
    SearchTranscriptView()
}
