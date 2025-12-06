//
//  PlayerAddTeamAccessCodeView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-11-23.
//

import SwiftUI
import GameFrameIOSShared

/**
 * A view that allows a player to join a team using an access code.
 *
 * This screen is presented when a player needs to enter the team access code
 * provided by their coach in order to join a specific team.
 *
 * ## Key Features:
 * - **Instruction Text**: Explains to the player what the access code is for.
 * - **Input Field**: A text field where the player enters the team access code.
 * - **Submit Button**: Triggers the `onSubmit` callback when a non-empty access code is entered.
 * - **Dismiss Button**: Allows the player to close the view and clears the entered code.
 *
 * ## Usage:
 * - Embed this view in a sheet or navigation stack.
 * - Bind `groupCode` to a state variable in the parent and implement `onSubmit`
 *   to validate and submit the access code.
 */
struct PlayerAddTeamAccessCodeView: View {
    /// The team access code entered by the player.
    /// This value is bound to the text field and updated as the user types.
    @Binding var groupCode: String

    /// Callback invoked when the player taps the "Submit" button.
    /// The parent view is responsible for validating and handling the access code.
    var onSubmit: () -> Void
    
    /// Environment value used to dismiss the view (e.g., closing a sheet).
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                // Header and explanation
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
                
                // Access code input and submit button row
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
                        // Button appears disabled-style when no code is entered.
                        .background(groupCode.isEmpty ? Color.secondary : Color.black)
                        .cornerRadius(30)
                    }
                    // Prevent submit when the access code is empty.
                    .disabled(groupCode.isEmpty)
                }
                .padding(.horizontal, 15)

                Spacer()
            }
            .padding(.top, 0)
            .toolbar {
                // Leading toolbar item: dismiss/close button
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        groupCode = "" // Reset the group access code entered
                        dismiss()      // Dismiss the view
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                            .frame(width: 40, height: 40) // Make it square
                            .background(
                                Circle()
                                    .fill(Color(uiColor: .systemGray6))
                            )
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
        // Preview onSubmit action
    })
}
