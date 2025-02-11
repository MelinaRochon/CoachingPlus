//
//  CoachMyTeamView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-05.
//

import SwiftUI

/***This structure shows all the footages and players related to the selected team. **/
struct CoachMyTeamView: View {
    @State private var selectedSegmentIndex = 0
    @State private var showAddPlayersSection = false
    let segmentTypes = ["Footage", "Players"]
    @State var teamName: String = "";
    //@State private var path = NavigationPath() // Stores the navigation history
    var body: some View {
        NavigationView {
            VStack {
                Divider()
                
                Picker("Type of selection - Segmented", selection: $selectedSegmentIndex) {
                    ForEach(segmentTypes.indices, id: \.self) { i in
                        Text(self.segmentTypes[i])
                    }
                }.pickerStyle(.segmented)
                    .padding(.leading).padding(.trailing)
                
                List {
                    if (selectedSegmentIndex == 0) {
                        Section(header: HStack {
                            Text("This week") // Section header text
                        }) {
                            HStack (alignment: .top) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 110, height: 60)
                                    .cornerRadius(10)
                                
                                VStack {
                                    Text("Game A vs C").font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Text("mm/dd/yyyy").font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            
                        }
                        
                        Section(header: HStack {
                            Text("Last 30 days") // Section header text
                        }) {
                            HStack (alignment: .top) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 110, height: 60)
                                    .cornerRadius(10)
                                
                                VStack {
                                    Text("Game A vs B").font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Text("mm/dd/yyyy").font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            
                            HStack (alignment: .top) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 110, height: 60)
                                    .cornerRadius(10)
                                
                                VStack {
                                    Text("Game A vs Y").font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Text("mm/dd/yyyy").font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                    } else {
                        Section(header:
                            HStack {
                                //Text("Adding Players").font(.headline).bold()
                                Spacer()
                            
                                NavigationLink(destination: CoachAddPlayersView(player: .init(name: "Melina Rochon", dob: Date(), jersey: 34, gender: 1, email: "moch072@u.com", guardianName: "", guardianEmail: "", guardianPhone: ""))) {
                                
                                    // Open create new team form
                                    Text("Add +")
                                }
                        }){
                            NavigationLink(destination: CoachPlayerProfileView(player: .init(name: "John Doe", dob: Date(), jersey: 67, gender: 1, email: "johnDoe@u.com", guardianName: "Terry Doe", guardianEmail: "doe@gmail.com", guardianPhone: "545-234-9009"))) {
                                Text("John Doe")
                            }
                                           
                            NavigationLink(destination: CoachPlayerProfileView(player: .init(name: "Dany Joe", dob: Date(), jersey: 1, gender: 1, email: "danyJ@u.com", guardianName: "", guardianEmail: "", guardianPhone: ""))) {
                                Text("Dany Joe")
                            }
                            
                        }
                        
                    }
                    
                }.listStyle(PlainListStyle()) // Optional: Make the list style more simple
                    .background(Color.white) // Set background color to white for the List
                  
            }.navigationTitle(Text(teamName))
            
            
        }
    }
}

#Preview {
    CoachMyTeamView(teamName: "Team 1")
}
