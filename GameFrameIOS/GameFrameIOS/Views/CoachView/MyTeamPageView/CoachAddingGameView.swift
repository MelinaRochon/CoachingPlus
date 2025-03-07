//
//  CoachAddingGameView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-05.
//

import SwiftUI

struct CoachAddingGameView: View {
    @State var newGame: Game
    @Environment(\.dismiss) var dismiss // To go back to the Teams page, if needed
    @State var timeString = ""
    @State var hours: Int = 0
    @State var minutes: Int = 0
    @State private var location: LocationResult? // Store the selected location

        
    private func formatTime() {
        var timeFormatter : DateFormatter {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            formatter.locale = Locale(identifier: "tr_TR") // your locale here
            return formatter
        }
        
        timeString = timeFormatter.string(from: newGame.duration)
    }
    
    
    
    var body: some View {
        NavigationView {
            
//            ScrollView {
                //
                VStack(alignment: .leading) {
                    //Text("New Game").font(.title3).bold().padding(.bottom)
                    
                    Form {
                        Section {
                            HStack {
                                Text("Title")
                                Spacer()
                                TextField("Title", text: $newGame.title).foregroundStyle(.secondary).multilineTextAlignment(.trailing)
                            }
                            
                            HStack {
                                VStack {
                                    Text("Duration")
                                    HStack {
                                        Picker("", selection: $hours){
                                            ForEach(0..<4, id: \.self) { i in
                                                Text("\(i) hours").tag(i)
                                            }
                                        }.pickerStyle(WheelPickerStyle())
                                        Picker("", selection: $minutes){
                                            ForEach(0..<60, id: \.self) { i in
                                                Text("\(i) min").tag(i)
                                            }
                                        }.pickerStyle(WheelPickerStyle())
                                    }
                                }
                            }
                            HStack {
                                Text("Location")
                                
                                NavigationLink(destination: LocationView(location: $location), label: {
                                    HStack {
                                        Spacer()
                                        if let location = location {
                                            Text("\(location.title) \(location.subtitle)").multilineTextAlignment(.trailing)
                                        } else {
                                            Text("Enter location").foregroundStyle(.secondary)
                                        }
                                    }
                                    
                                }).isDetailLink(true)
                                
                                /*Button(action: { logoIsPresented.toggle()}) {
                                 Text("Choose").contentShape(Rectangle())
                                 }.sheet(isPresented: $logoIsPresented, content: {
                                 SymbolsPicker(selection: $team.icon, title: "Choose your team's logo", autoDismiss: true) {
                                 Image(systemName: "xmark.diamond.fill")
                                 }
                                 })*/
                                
                                //Image(systemName: team.icon).foregroundStyle(team.color)
                            }
                            HStack {
                                //Text("Scheduled Time")
                                DatePicker("Scheduled Time", selection: $newGame.scheduledTime).frame(width: 325, height: 50)
                            }
                        }
                        
                        Section {
                            /*Picker("Gender", selection: $team.gender)
                             {
                             ForEach(genders.indices, id: \.self) {i in
                             Text(self.genders[i])
                             }
                             }
                             HStack {
                             Picker("Age group", selection: $team.ageGrp)
                             {
                             ForEach(ageGroupes, id: \.self) {
                             Text($0)
                             }
                             }
                             }*/
                            HStack {
                                Text("Sport")
                                Spacer()
                                TextField("Sport", text: $newGame.sport).foregroundStyle(.secondary).multilineTextAlignment(.trailing)
                            }
                            
                            HStack {
                                Text("Time Before Feedback")
                                Spacer()
                            }
                            
                            HStack {
                                Text("Time After Feedback")
                                Spacer()
                            }
                        }
                        
                        Section(footer:
                                    Text("Will send recording reminder at the scheduled time.")
                        ){
                            Toggle("Get Recording Reminder", isOn: $newGame.getRecordingReminder)
                        }
                        
                        /*Section(header:
                         HStack {
                         Text("Adding Players").font(.headline).bold()
                         Spacer()
                         NavigationLink(destination: CoachAddPlayersView(player: .init(name: "Melina Rochon", dob: Date(), jersey: 34, gender: 1, email: "moch072@u.com", guardianName: "", guardianEmail: "", guardianPhone: ""))) {
                         
                         // Open create new team form
                         Text("Add +")
                         }
                         }){
                         Text("John Dow")
                         /*List {
                          ForEach(players) { player in
                          NavigationLink {
                          Text("Item at")
                          } label: {
                          Text(player.name)
                          }
                          }
                          }*/
                         }*/
                        /** Check if the list is scrollable!! Make sure it is. */
                        
                    // }
                }
            }.toolbar {
                ToolbarItem(placement: .topBarLeading) { // Back button on the top left
                                    Button(action: {
                                        dismiss() // Dismiss the full-screen cover
                                    }) {
                                        HStack {
                                            Image(systemName: "chevron.left")
                                            Text("Back")
                                        }
                                    }
                                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { /* Action will need to be added -> complete team form */}) {
                        Text("Done")
                    }
                }
            }.navigationBarTitleDisplayMode(.inline)
                .navigationTitle(Text("New Game"))
                
        }
    }
}

#Preview {
    CoachAddingGameView(newGame: .init(title: "Game PSG VS Real Madrid", duration: Date(timeIntervalSinceNow: 3600), location: "Parc des Princes, Paris, France", scheduledTime: Date(), sport: "Soccer", timeBeforeFeedback: Date(timeIntervalSinceNow: 2000), timeAfterFeedback: Date(timeIntervalSinceNow: 2000), getRecordingReminder: true))
}
