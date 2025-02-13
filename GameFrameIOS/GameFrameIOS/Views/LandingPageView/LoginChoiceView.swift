//
//  LoginChoiceView.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-02-13.
//

import SwiftUI

struct LoginChoiceView: View {
    var body: some View {
        NavigationView {
            
            VStack(spacing: 20) {
                
                // HEADER
                HStack {
                    VStack(alignment: .leading) {
                        Text("GameFrame")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("leveling up your game")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    NavigationLink(destination: CreateAccountChoiceView()){
                        HStack {
                            Text("Create account").foregroundColor(.gray)
                            
                            Image(systemName: "person.crop.circle.badge.plus")
                                .resizable()
                                .frame(width: 28, height: 24)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.horizontal)
                ScrollView {
                    Spacer().frame(height: 50)
                    
                    // CALL TO ACTION
                    VStack(spacing: 10) {
                        Text("Log in as a..")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        HStack(spacing: 10) {
                            NavigationLink(destination: CoachLoginView()) {
                                Text("Coach")
                                    .font(.headline)
                                    .padding()
                                    .frame(width: 100, height: 40)
                                    .background(Color.black)
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                            }
                            
                            NavigationLink(destination: PlayerLoginView()) {
                                Text("Player")
                                    .font(.headline)
                                    .padding()
                                    .frame(width: 100, height: 40)
                                    .background(Color.black)
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    
                }
            }
        }
    }
}

#Preview {
    LoginChoiceView()
}
