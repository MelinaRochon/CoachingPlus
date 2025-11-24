//
//  UpdatingPlayerInfoView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-11-20.
//

import SwiftUI
import GameFrameIOSShared

struct UpdatingPlayerInfoView: View {
    
    @Environment(\.dismiss) var dismiss

    @Binding var selectedPositions: Set<SoccerPosition>
    @Binding var nickname: String
    @Binding var jersey: Int
    @State private var isNavigating = false
    
    @State var playerNickname: String
    @State var playerJersey: Int
    @State var playerSelectedPositions: Set<SoccerPosition>
    
    var showToolbarButtons: Bool = true

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                CustomUIFields.customTitle("Review Player Details", subTitle: "Make changes to the player's nickname, jersey and field roles.")

                ScrollView {
                    
                    
                    ReviewPlayerDetailsView(
                        selectedPositions: $selectedPositions,
                        nickname: $nickname,
                        jersey: $jersey,
                        playerNickname: nickname,
                        playerJersey: jersey,
                        playerSelectedPositions: selectedPositions,
                        showToolbarButtons: true
                    )
                    .padding(.top, 30)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        selectedPositions = []
                        jersey = 0
                        nickname = ""
                        dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")   // your icon
                                .font(.headline)
                        }
                    }
                    .opacity(showToolbarButtons ? 1 : 0)
                }

                ToolbarItem(placement: .bottomBar) {
                    Button {
                        dismiss()
                    } label: {
                        HStack {
                            Text("Save Player Information").font(.body).bold()
                        }
                        .padding(.horizontal, 25)
                        .foregroundColor(.white)
                        .padding(.vertical, 15)
                        .background(Capsule().fill(!isValidNickname && !isValidJerseyNumber && !isValidPositions ? Color.secondary : Color.black))
                    }
                    .disabled(!isValidNickname && !isValidJerseyNumber && !isValidPositions)
                    .opacity(showToolbarButtons ? 1 : 0)
                }
            }
        }
        .toolbarBackground(.clear, for: .bottomBar)
        .scrollDismissesKeyboard(.immediately)
        .frame(maxWidth: .infinity, alignment: .top) // ensure it aligns to top
        .navigationBarBackButtonHidden(true)

    }
    
}

extension UpdatingPlayerInfoView: AddingPlayerToTeam {
    var isValidNickname: Bool {
        return !nickname.isEmpty && isValidName(nickname) && playerNickname != nickname
    }
    
    var isValidJerseyNumber: Bool {
        return jersey != 0 && jersey != playerJersey
    }
    
    var isValidPositions: Bool {
        return selectedPositions != [] && selectedPositions != playerSelectedPositions
    }
}
