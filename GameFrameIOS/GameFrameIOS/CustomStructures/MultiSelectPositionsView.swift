//
//  MultiSelectPositionsView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-11-20.
//

import SwiftUI
import GameFrameIOSShared

struct MultiSelectPositionsView: View {
    @Binding var selected: Set<SoccerPosition>
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            CustomUIFields.customTitle("Select Player Positions", subTitle: "Choose all the positions this player can play.")
            List {
                ForEach(SoccerPosition.allCases) { position in
                    HStack {
                        Text(position.fullName)
                        Spacer()
                        if selected.contains(position) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        } else {
                            Image(systemName: "circle")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    .contentShape(Rectangle())
                    .onTapGesture {
                        toggle(position)
                    }
                }
            }
            .listStyle(.plain)
            .padding(.horizontal, 15)
        }
        .navigationBarBackButtonHidden(true)   // Hide default
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")   // your icon
                            .font(.headline)
                    }
                }
            }
        }
        
    }

    private func toggle(_ pos: SoccerPosition) {
        if selected.contains(pos) {
            selected.remove(pos)
        } else {
            selected.insert(pos)
        }
    }
}

#Preview {
    @Previewable @State var selected: Set<SoccerPosition> = []

    NavigationStack {
        MultiSelectPositionsView(selected: $selected)
    }
}
