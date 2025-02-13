//
//  CreateAccountChoiceView.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-02-13.
//

import SwiftUI

struct CreateAccountChoiceView: View {
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
                    
                    NavigationLink(destination: LoginChoiceView()){
                        HStack {
                            Text("Log in").foregroundColor(.gray)
                            
                            Image(systemName: "person.circle")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.horizontal)
                ScrollView {
                    Spacer().frame(height: 50)
                    
                    // CALL TO ACTION
                    VStack(spacing: 10) {
                        Text("Create an account as a..")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        HStack(spacing: 10) {
                            NavigationLink(destination: CoachCreateAccountView()) {
                                Text("Coach")
                                    .font(.headline)
                                    .padding()
                                    .frame(width: 100, height: 40)
                                    .background(Color.black)
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                            }
                            
                            NavigationLink(destination: PlayerCreateAccountView()) {
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
    CreateAccountChoiceView()
}
