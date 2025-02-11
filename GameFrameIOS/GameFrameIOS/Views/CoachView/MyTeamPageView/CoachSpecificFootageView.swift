//
//  CoachSpecificFootageView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-05.
//

import SwiftUI

struct CoachSpecificFootageView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    HStack(alignment: .top) {
                        VStack {
                            Text("Game X VS Y").font(.title2)
                            Text("Team 1").font(.headline).foregroundStyle(.black.opacity(0.9))
                            Text("dd/mm/yyyy").font(.subheadline).foregroundStyle(.secondary)
                            Text("Location").font(.subheadline).foregroundStyle(.secondary).italic(true).foregroundStyle(.secondary).italic(true).padding(.bottom, 2)
                            Divider()
                        }
                        
                    }
                    
                    // Watch Full Game
                    VStack(alignment: .leading, spacing: 0) {
                        NavigationLink(destination: CoachFullGameTranscriptView()) {
                            Text("Full Game Transcript")
                                .font(.headline)
                                .foregroundColor(.black)
                            Spacer()
                            Text("Watch").foregroundColor(.gray)
                            Image(systemName: "chevron.right").foregroundColor(.gray)
                        }
                    }.padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 1))
                        .padding(.horizontal).padding(.top)
                    
                    // Key moments
                    VStack(alignment: .leading, spacing: 10) {
                        NavigationLink(destination: CoachAllKeyMomentsView()) {
                            Text("Key moments")
                                .font(.headline)
                                .foregroundColor(.black)
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.black)
                            Spacer()
                            
                        }.padding(.bottom, 4)
                        
                        HStack (alignment: .top) {
                            
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 110, height: 60)
                                .cornerRadius(10)
                            NavigationLink(destination: CoachSpecificKeyMomentView()) {
                                VStack {
                                    HStack {
                                        Text("hh:mm:ss").font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).padding(.bottom, 2).foregroundStyle(.black)
                                        Spacer()
                                        Image(systemName: "person.crop.circle").resizable().frame(width: 22, height: 22).foregroundStyle(.gray)
                                    }
                                    
                                    Text("Transcript: \"Lorem ipsum dolor sit amet, consectetur adipiscing...\"").font(.caption).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading).foregroundStyle(.black)
                                    Divider().padding(.vertical, 2)
                                }
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
                                Divider().padding(.vertical, 2)
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
                                    Image(systemName: "person.2.circle").resizable().frame(width: 22, height: 22).foregroundStyle(.gray)
                                }
                                
                                Text("Transcript: \"Lorem ipsum dolor sit amet, consectetur adipiscing...\"").font(.caption).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                Divider().padding(.vertical, 2)
                            }
                        }
                        
                    }.padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 1))
                        .padding(.horizontal).padding(.top)
                    
                    // Transcript
                    VStack(alignment: .leading, spacing: 10) {
                        
                        NavigationLink(destination: CoachAllTranscriptsView()) {
                            Text("Transcript")
                                .font(.headline)
                                .foregroundColor(.black)
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.black)
                            Spacer()
                            
                        }.padding(.bottom, 4)
                        
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
                                    Image(systemName: "person.2.circle").resizable().frame(width: 22, height: 22).foregroundStyle(.gray)
                                }
                            }
                        }
                    }.padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 1))
                        .padding(.horizontal).padding(.top)
                    
                }
            }.frame(maxHeight: .infinity, alignment: .top)
        }
    }
    
    
}

#Preview {
    CoachSpecificFootageView()
}
