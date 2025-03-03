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
                
                ScrollView {
                    Spacer().frame(height: 50)
                    Text("This page should not be used! ")
                    // CALL TO ACTION
                    VStack(spacing: 10) {
                        Text("Create an account as a..")
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        HStack(spacing: 10) {
                            NavigationLink(destination: CoachCreateAccountView(showSignInView: .constant(false))) {
                                Text("Coach")
                                    .font(.headline)
                                    .padding()
                                    .frame(width: 100, height: 40)
                                    .background(Color.black)
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                            }
                            
                            NavigationLink(destination: PlayerCreateAccountView(showSignInView: .constant(false))) {
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
