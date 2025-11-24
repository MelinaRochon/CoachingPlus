//
//  CustomDivier.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-11-23.
//

import SwiftUI

/// A customizable divider with optional subtitle and optional navigation destination
struct CustomDividerWithNavigationLink<Destination: View>: View {
    
    let title: String
    let subTitle: String
    var subTitleColor: Color = .gray
    let destinationBuilder: (() -> Destination)  // closure that returns the destination view

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                    .font(.footnote)
                    .fontWeight(.medium)
                    .textCase(.uppercase)
                
                Spacer()
                
                NavigationLink(destination: destinationBuilder()) {
                    Text(subTitle)
                        .font(.footnote)
                        .textCase(.uppercase)
                        .foregroundColor(subTitleColor)
                }
            }
            Divider()
        }
    }
}
