//
//  CoachAllKeymomentsView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-11.
//

import SwiftUI

/*** Shows all recorded key moments from a specific game. */
struct CoachAllKeyMomentsView: View {
    @State private var searchText: String = ""
    var body: some View {
        NavigationView {
            VStack {
                List  {
                    Section {
                        HStack (alignment: .top) {
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
                        
                        HStack (alignment: .top) {
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
                        
                        HStack (alignment: .top) {
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
                        
                        HStack (alignment: .top) {
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
                .listStyle(PlainListStyle()) // Optional: Make the list style more simple
            }
            
        }.searchable(text: $searchText)
    }
}

#Preview {
    CoachAllKeyMomentsView()
}
