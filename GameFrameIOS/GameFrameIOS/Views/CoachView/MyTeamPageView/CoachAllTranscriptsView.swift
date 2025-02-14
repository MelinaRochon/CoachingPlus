//
//  CoachAllTranscriptsView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-05.
//

import SwiftUI

struct CoachAllTranscriptsView: View {
    @State private var searchText: String = ""
    @State private var showFilterSelector = false
    
    var body: some View {
        //NavigationView {
            VStack (alignment: .leading) {
                VStack (alignment: .leading) {
                    HStack(spacing: 0) {
                        Text("Game X VS Y").font(.title2)
                        Spacer()
                        Button (action: {
                            showFilterSelector.toggle()
                        }) {
                            Image(systemName: "line.3.horizontal.decrease.circle").resizable().frame(width: 20, height: 20)
                        }
                    }
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Team 1").font(.subheadline).foregroundStyle(.black.opacity(0.9))
                            Text("dd/mm/yyyy hh:mm:ss").font(.subheadline).foregroundStyle(.secondary)
                        }
                        Spacer()
                        // Edit Icon
                        Button(action: {}) {
                            Image(systemName: "pencil.and.outline")
                                .foregroundColor(.blue) // Adjust color
                        }
                        // Share Icon
                        Button(action: {}) {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.blue) // Adjust color
                        }
                    }
                }.padding(.leading).padding(.trailing).padding(.top, 3)
                
                Divider().padding(.vertical, 2)
                                
                SearchTranscriptView()
            }// Show filters
            .sheet(isPresented: $showFilterSelector, content: {
                FilterTranscriptsListView().presentationDetents([.medium])
            })

        //}
        
    }
}

#Preview {
    CoachAllTranscriptsView()
}
