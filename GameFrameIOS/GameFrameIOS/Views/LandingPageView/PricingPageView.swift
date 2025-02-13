//
//  PricingPageView.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-02-13.
//

import SwiftUI

struct PricingPageView: View {
    @State private var selectedPlan: String = "Select a plan to see details"

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
                    VStack(spacing: 10) {
                                Text("View our plans!")
                                    .font(.title2)
                                    .fontWeight(.bold)
                        
                                
                                
                                
                                HStack(spacing: 10) {
                                    pricingButton(title: "Free", description: "Limited features, no cost!")
                                    pricingButton(title: "Plus", description: "More features for personal use!")
                                    pricingButton(title: "Premium", description: "Best for teams and professionals!")
                                }
                            }
                            .padding()
                    
                    // Dynamic Text Box
                    Text(selectedPlan)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                        .multilineTextAlignment(.center)
                    
                    
                }
            }
        }
    }
    
    func pricingButton(title: String, description: String) -> some View {
        Button(action: {
            selectedPlan = description
        }) {
            Text(title)
                .font(.headline)
                .padding()
                .frame(width: 120, height: 40)
                .background(selectedPlan == description ? Color.gray : Color.black) // Change color if selected
                .foregroundColor(.white)
                .clipShape(Capsule())
        }
    }
}


#Preview {
    PricingPageView()
}
