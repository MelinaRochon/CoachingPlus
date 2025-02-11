//
//  CoachNotificationView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-05.
//

import SwiftUI

/***
 This structure is the recent activity view. All the recent acitivities made in the app (all types of notifications) will be shown here.
 */
struct CoachNotificationView: View {
    var body: some View {
        NavigationView {
            VStack {
                
                Divider() // This adds a divider after the title
                
                List {
                    Section(header: HStack {
                        Text("Notifications") // Section header text
                    }) {
                        
                        // Notification 1
                        HStack {
                            Image(systemName: "person.crop.circle").resizable().frame(width: 30, height: 30).aspectRatio(contentMode: .fill)
                                .clipShape(Circle())
                                .clipped()
                            VStack {
                                Text("X commented on Game 1...").font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                Text("1 hour ago").font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        
                        // Notification 2
                        HStack {
                            Image(systemName: "person.crop.circle").resizable().frame(width: 30, height: 30).aspectRatio(contentMode: .fill)
                                .clipShape(Circle())
                                .clipped()
                            VStack {
                                Text("X commented on Game 1...").font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                Text("1 hour ago").font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        
                        // Notification 3
                        HStack {
                            Image(systemName: "person.crop.circle").resizable().frame(width: 30, height: 30).aspectRatio(contentMode: .fill)
                                .clipShape(Circle())
                                .clipped()
                            VStack {
                                Text("X commented on Game 1...").font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                Text("1 hour ago").font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle()) // Optional: Make the list style more simple
                .background(Color.white) // Set background color to white for the List
                
            }
            .background(Color.white)
            .navigationTitle(Text("Recent Activity"))
            
        }
        
    }
}

#Preview {
    CoachNotificationView()
}
