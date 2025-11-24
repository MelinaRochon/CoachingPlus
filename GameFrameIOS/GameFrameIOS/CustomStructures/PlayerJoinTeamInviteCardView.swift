//
//  InviteToJoinTeamCard.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-11-22.
//

import SwiftUI

struct PlayerJoinTeamInviteCardView: View {
    var teamName: String
    var onAccept: () -> Void
    var onDecline: () -> Void

    var body: some View {
        
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "tshirt")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundStyle(.red)
                    .padding(.trailing, 5)
                VStack(alignment: .leading, spacing: 4) {
                    Text(teamName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .foregroundStyle(.black)
                    Text("Invitation to join team")
                        .font(.caption)
                        .padding(.leading, 1)
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.gray)
                    
                }
                Spacer()
                HStack {
                    
                    Button(action: onAccept) {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.green)
                            .frame(width: 35, height: 35)
                            .padding(.trailing, 5)
                    }
                    
                    Button(action: onDecline) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.red)
                            .frame(width: 35, height: 35)
                    }
                }
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.vertical, 10)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.4), lineWidth: 0.3)
            )
        }
        .background(
            RoundedRectangle(cornerRadius: 12).fill(Color(.white))
            
        )
        .frame(maxWidth: .infinity) // ← ensures the whole card uses full width
        .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
    }
}
