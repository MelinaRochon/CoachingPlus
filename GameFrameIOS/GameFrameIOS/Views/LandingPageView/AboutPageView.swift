//
//  AboutPageView.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-02-13.
//

import SwiftUI

struct AboutPageView: View {
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
                    Spacer().frame(height: 20)
                    Text("Hey there!")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("About us...")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    
                }
            }
        }
    }
}

#Preview {
    AboutPageView()
}
