//
//  AddDateAndTimeView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-11-24.
//

import SwiftUI

struct AddDateAndTimeView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var date: Date
    @Binding var dateAtStart: Date?
    
    var title: String
    var subTitle: String
    var body: some View {
        VStack {
            CustomUIFields.customTitle(title, subTitle: subTitle)

            VStack {
                DatePicker(
                    "",
                    selection: $date,
                    in: Date()...,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.graphical)
            }
            .padding(.horizontal, 15)

            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dateAtStart = date
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
}

#Preview {
    @Previewable @State var date: Date = Date()
    @Previewable @State var dateAtStart: Date? = nil
    AddDateAndTimeView(date: $date, dateAtStart: $dateAtStart, title: "Date & Time View", subTitle: "")
}
