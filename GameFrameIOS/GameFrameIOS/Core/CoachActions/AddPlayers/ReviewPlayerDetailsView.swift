//
//  ReviewPlayerDetailsView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-11-22.
//

import SwiftUI
import GameFrameIOSShared

struct ReviewPlayerDetailsView: View {
    
    @Environment(\.dismiss) var dismiss
    
    // Adding a new player information
    @State var firstName: String = ""
    @State var lastName = ""
    @State var guardianName: String = ""
    @State var guardianEmail: String = ""
    @State var guardianPhone: String = ""

    @Binding var selectedPositions: Set<SoccerPosition>
    @Binding var nickname: String
    @Binding var jersey: Int
    @State private var isNavigating = false
    
    @State var playerNickname: String
    @State var playerJersey: Int
    @State var playerSelectedPositions: Set<SoccerPosition>
    
    var showToolbarButtons: Bool = true

    var body: some View {
        VStack(alignment: .leading) {
            
            CustomUIFields.customDivider("Roster Information (Optional)")
            CustomTextField(label: "Nickname", text: $nickname, isRequired: false, disableAutocorrection: true)
            CustomTextFieldForNumbers(label: "Jersey #", value: $jersey, isRequired: false)
                .padding(.bottom, 30)
            
            CustomUIFields.customDivider("Player Positions (Optional)")
            CustomNavigationLinkDropdown(
                label: "Positions",
                placeholder: "Select Positions",
                valueText: {
                    return selectedPositions
                        .map { $0.rawValue }
                        .sorted()
                        .joined(separator: ", ")
                },
                isRequired: false,
                isActive: $isNavigating,
                destination: MultiSelectPositionsView(selected: $selectedPositions),
                onSelect: {
                    hideKeyboard()
                    isNavigating = true
                }
            )
            
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(selectedPositions.sorted(), id: \.self) { position in
                            Text(position.rawValue)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.red.opacity(0.2))
                                .foregroundColor(.primary)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            .frame(height: 20)
            .padding(.vertical, 10)
        }
        .padding(.horizontal)
    }
}
