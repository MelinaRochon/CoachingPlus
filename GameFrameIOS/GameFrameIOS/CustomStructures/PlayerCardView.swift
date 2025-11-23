//
//  PlayerCardView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-11-20.
//

import Foundation
import SwiftUI

struct PlayerCardView: View {
    let firstName: String
    let lastName: String
    let email: String
    let profileImage: Image?
    let isVerified: Bool
    
    @State private var showVerified = false
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if let profileImage = profileImage {
                    profileImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: 45, height: 45)
                        .clipShape(Circle())
                        .padding(.trailing, 5)
                } else {
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 45, height: 45)
                        .foregroundStyle(.gray)
                        .padding(.trailing, 5)
                }
                VStack (alignment: .leading, spacing: 4) {
                    Text("\(firstName) \(lastName)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.black)
                    Text(email)
                        .font(.caption)
                        .padding(.leading, 1)
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.gray)
                        .italic()
                    
                    HStack(spacing: 2) {
                        if isVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.green)
                                .opacity(showVerified ? 1 : 0)
                                .offset(y: showVerified ? 0 : 5)
                            
                            Text("Verified Player")
                                .foregroundStyle(.green)
                                .opacity(showVerified ? 1 : 0)
                                .offset(y: showVerified ? 0 : 5)
                        } else {
                            Image(systemName: "xmark.seal.fill")
                                .foregroundColor(.red)
                                .opacity(showVerified ? 1 : 0)
                                .offset(y: showVerified ? 0 : 5)
                            
                            Text("Unverified Player")
                                .foregroundStyle(.red)
                                .opacity(showVerified ? 1 : 0)
                                .offset(y: showVerified ? 0 : 5)
                        }
                    }
                    .animation(.easeOut(duration: 0.35), value: showVerified)
                    .font(.caption2)
                    
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .padding(.leading)
                    .padding(.trailing, 5)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading) // ← makes HStack expand
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.4), lineWidth: 0.3)
            )
        }
        .background(
            RoundedRectangle(cornerRadius: 12).fill(Color(.white)) // Color(red: 0.97, green: 0.97, blue: 0.98)

        )
        .frame(maxWidth: .infinity) // ← ensures the whole card uses full width
        .padding(.horizontal)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showVerified = true
            }
        }
        .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
    }
}

#Preview {
    ZStack {
        Color(.white)
            .ignoresSafeArea()
        
        PlayerCardView(firstName: "Jane", lastName: "Doe", email: "janeDoe@gmail.com", profileImage: nil, isVerified: true)
    }
}
