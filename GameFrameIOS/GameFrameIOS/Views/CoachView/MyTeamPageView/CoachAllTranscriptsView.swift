//
//  CoachAllTranscriptsView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-05.
//

import SwiftUI

struct CoachAllTranscriptsView: View {
    @State private var searchText: String = ""
    var body: some View {
        NavigationView {
            List  {
                Section {
                    HStack (alignment: .top) {
                        VStack {
                            HStack (alignment: .top) {
                                Text("hh:mm:ss").font(.headline).multilineTextAlignment(.leading).padding(.bottom, 2)
                                Spacer()
                                Text("Transcript: \"Lorem ipsum dolor sit amet, consectetur adipiscing...\"").font(.caption).padding(.top, 4)
                                Image(systemName: "person.circle").resizable().frame(width: 22, height: 22).foregroundStyle(.gray)
                            }
                            Divider().padding(.vertical, 2)
                        }
                    }
                        
                    HStack (alignment: .top) {
                        VStack {
                            HStack (alignment: .top) {
                                Text("hh:mm:ss").font(.headline).multilineTextAlignment(.leading).padding(.bottom, 2)
                                Spacer()
                                Text("Transcript: \"Lorem ipsum dolor sit amet, consectetur adipiscing...\"").font(.caption).padding(.top, 4)
                                Image(systemName: "person.circle").resizable().frame(width: 22, height: 22).foregroundStyle(.gray)
                            }
                            Divider().padding(.vertical, 2)
                        }
                    }
                    
                    HStack (alignment: .top) {
                        VStack {
                            HStack (alignment: .top) {
                                Text("hh:mm:ss").font(.headline).multilineTextAlignment(.leading).padding(.bottom, 2)
                                Spacer()
                                Text("Transcript: \"Lorem ipsum dolor sit amet, consectetur adipiscing...\"").font(.caption).padding(.top, 4)
                                Image(systemName: "person.circle").resizable().frame(width: 22, height: 22).foregroundStyle(.gray)
                            }
                            Divider().padding(.vertical, 2)
                        }
                    }
                    
                    HStack (alignment: .top) {
                        VStack {
                            HStack (alignment: .top) {
                                Text("hh:mm:ss").font(.headline).multilineTextAlignment(.leading).padding(.bottom, 2)
                                Spacer()
                                Text("Transcript: \"Lorem ipsum dolor sit amet, consectetur adipiscing...\"").font(.caption).padding(.top, 4)
                                Image(systemName: "person.circle").resizable().frame(width: 22, height: 22).foregroundStyle(.gray)
                            }
                            Divider().padding(.vertical, 2)
                        }
                    }
                    
                }
            }
            .listStyle(PlainListStyle()) // Optional: Make the list style more simple
        }.searchable(text: $searchText)
    }
}

#Preview {
    CoachAllTranscriptsView()
}
