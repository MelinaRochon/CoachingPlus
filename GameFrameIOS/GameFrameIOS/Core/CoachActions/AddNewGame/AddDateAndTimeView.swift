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

//#Preview {
//    @Previewable @State var date: Date = Date()
//    @Previewable @State var dateAtStart: Date? = nil
//    AddDateAndTimeView(date: $date, dateAtStart: $dateAtStart, title: "Date & Time View", subTitle: "")
//}



struct AddDurationView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var hours: Int // = 0
    @Binding var minutes: Int // = 0
    
    var title: String
    var subTitle: String
    var body: some View {
        VStack {
            CustomUIFields.customTitle(title, subTitle: subTitle)

            HStack {
                Picker("", selection: $hours){
                    ForEach(0..<13, id: \.self) { i in
                        Text("\(i)").tag(i)
                    }
                }.pickerStyle(.wheel).frame(width: 60, height: 100)
                    .clipped()
                Text("hours").fontWeight(.medium)
                
                // Picker for selecting the number of minutes for game duration
                Picker("", selection: $minutes){
                    ForEach(0..<60, id: \.self) { i in
                        Text("\(i)").tag(i)
                    }
                }.pickerStyle(.wheel).frame(width: 60, height: 100)
                Text("minutes").fontWeight(.medium)
            }
            .padding(.horizontal, 15)
            .padding(.top)
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
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
}
