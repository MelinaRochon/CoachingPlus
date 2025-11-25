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
    var icon: String? = nil
    var iconColor: Color = .red
    
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
                    HStack {
                        Text(subTitle)
                            .font(.footnote)
                            .textCase(.uppercase)
                            .fontWeight(.medium)
                            .foregroundColor(subTitleColor)
                        
                        if let icon = icon {
                            Image(systemName: icon)
                                .foregroundStyle(iconColor)
                        }

                    }
                }
            }
            Divider()
        }
    }
}
