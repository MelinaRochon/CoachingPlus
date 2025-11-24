
///
///  CustomListSection.swift
///  GameFrameIOS
///
///  Created by Mélina Rochon on 2025-11-23.
///

import Foundation
import SwiftUI

/// Reusable scrollable list with section header and optional loading indicator
struct CustomListSection<Item: Identifiable, Destination: View>: View {

//    /// Section title
//    let title: String
    
    let titleContent: () -> AnyView
    /// Data to iterate over
    let items: [Item]?
    
    /// Indicates if the data is loading
    let isLoading: Bool
    var rowLogo: String? = nil
    var rowLogoColor: Color = .red
    var rowChevronDisplay: Bool = true
    var isLoadingProgressViewTitle: String = "Loading"
    var noItemsFoundIcon: String? = nil
    var noItemsFoundTitle: String = "No items found"
    var noItemsFoundSubtitle: String? = nil
    
    let destinationBuilder: (Item) -> Destination

    
    /// Row content builder
    let rowContent: (Item) -> AnyView
    
    var body: some View {
        VStack {
//            CustomUIFields.customDivider(title)
            titleContent()
                .padding(.bottom, 0)
                .padding(.horizontal, 15)
            
            if isLoading {
                VStack {
                    ProgressView(isLoadingProgressViewTitle)
                        .padding()
                        .background(.white)
                        .cornerRadius(12)
                }
                .padding(.top, 10)
                .frame(maxWidth: .infinity)
            } else {
                if let items = items, !items.isEmpty {
                    ScrollView {
                        VStack {
                            ForEach(items) { item in
                                NavigationLink(destination: destinationBuilder(item)
                                ) {
                                    VStack {
                                        HStack {
                                            if let logo = rowLogo {
                                                Image(systemName: logo)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 30, height: 30)
                                                    .foregroundStyle(rowLogoColor)
                                                    .padding(.trailing, 5)
                                            }
                                            rowContent(item)
                                            Spacer()
                                            if rowChevronDisplay {
                                                Image(systemName: "chevron.right")
                                                    .foregroundColor(.gray)
                                                    .padding(.leading)
                                                    .padding(.trailing, 5)
                                            }
                                        }
                                        .padding(.vertical, 5)
                                        Divider()
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 15)
//                        .padding(.bottom, 10)
                    }
                    .safeAreaInset(edge: .bottom){ // Adding padding space for nav bar
                        Color.clear.frame(height: 75)
                    }
                } else {
                    VStack(alignment: .center) {
                        if let icon = noItemsFoundIcon {
                            Image(systemName: icon)
                                .font(.system(size: 30))
                                .foregroundColor(.gray)
                                .padding(.bottom, 2)
                        }
                        
                        Text(noItemsFoundTitle).font(.headline).foregroundStyle(.secondary)
                        
                        if let subTitle = noItemsFoundSubtitle {
                            Text(subTitle)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.top, 10)
                }
            }
        }
    }
}
