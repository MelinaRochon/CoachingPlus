//
//  PlayerAddTeamAccessCodeView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-11-23.
//

import SwiftUI
import GameFrameIOSShared

struct PlayerAddTeamAccessCodeView: View {
    @Binding var groupCode: String
    var onSubmit: () -> Void
    
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                VStack(alignment: .center) {
                    Text("Join your Team")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("Enter the access code provided by your coach to join your team.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }
                Divider()
                
                HStack(alignment: .bottom) {
                    CustomTextField(
                        label: "Team Access Code",
                        placeholder: "Your Code",
                        text: $groupCode,
                        isRequired: true,
                        disableAutocorrection: true,
                        autoCapitalization: false
                    )
                    
                    Button(action: onSubmit) {
                        HStack {
                            Text("Submit").font(.subheadline)
                            Image(systemName: "arrow.right")
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 11)
                        .background(groupCode.isEmpty ? Color.secondary : Color.black)
                        .cornerRadius(30)
                    }.disabled(groupCode.isEmpty)
                }
                .padding(.horizontal, 15)
                Spacer()
            }
            .padding(.top, 0)
            
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        groupCode = "" // Reset the group access code entered
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray) // Make text + icon white
                            .frame(width: 40, height: 40) // Make it square
                            .background(Circle().fill(Color(uiColor: .systemGray6)))
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 0)
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var groupCode = "code123"
    PlayerAddTeamAccessCodeView(groupCode: $groupCode, onSubmit: {
        
    })
}
