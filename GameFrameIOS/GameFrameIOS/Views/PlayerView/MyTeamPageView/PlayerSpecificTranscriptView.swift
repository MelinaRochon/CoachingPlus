//
//  PlayerSpecificTranscriptView.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-02-05.
//

import SwiftUI

struct PlayerSpecificTranscriptView: View {
    var body: some View {
            ScrollView {
                VStack {
                    VStack (alignment: .leading) {
                        HStack(spacing: 0) {
                            Text("Game X VS Y").font(.title2)
                            Spacer()
                            
                        }
                        HStack {
                            Text("Transcript #").font(.headline)
                            Spacer()
                        }.padding(.bottom, -2)
                        
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
                    
                    // Transcription section
                    VStack(alignment: .leading) {
                        Text("hh:mm:ss").font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal).padding(.bottom, 2)
                        Text("\"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.\"").font(.caption).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal)
                    }.padding(.bottom, 10).padding(.top)
                    
                    
                    // Feedback for section
                    VStack(alignment: .leading) {
                        Text("Feedback For").font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.top, 10)
                        
                        HStack {
                            Image(systemName: "person.circle").resizable().frame(width: 22, height: 22).foregroundStyle(.gray).padding(.vertical, 5)
                            Text("John Doe")
                        }
                    }.padding(.horizontal)
                    
                    VStack {
                        Divider()
                            
                        // TODO: Comment section
                        //CommentSectionView(viewModel: <#T##KeyMomentViewModel#>, teamId: <#T##String#>, keyMomentId: <#T##String#>)
                        
                    }.frame(maxHeight: .infinity, alignment: .bottom)
                }
            }
        }
    }


#Preview {
    PlayerSpecificTranscriptView()
}
