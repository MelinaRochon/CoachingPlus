//
//  LoginChoiceView.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-02-13.
//

import SwiftUI

struct LoginChoiceView: View {
    
    @Binding var showSignInView: Bool
    
    var body: some View {
        NavigationView {
            
            VStack(spacing: 20) {
                                
                ScrollView {
                    Spacer().frame(height: 50)
                    
                    // CALL TO ACTION
                    VStack(spacing: 10) {
                        Text("Log in as a..")
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        HStack(spacing: 10) {
                            NavigationLink(destination: CoachAuthenticationView(showSignInView: $showSignInView)) {
                                Text("Coach")
                                    .font(.headline)
                                    .padding()
                                    .frame(width: 100, height: 40)
                                    .background(Color.black)
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                            }
                            
                            NavigationLink(destination: PlayerLoginView(showSignInView: $showSignInView)) {
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
    LoginChoiceView(showSignInView: .constant(false))
}
