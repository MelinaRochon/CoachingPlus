//
//  CoachPlayerProfileView.swift
//  GameFrameIOS
//  Coach views the player's profile!
//
//  Created by Mélina Rochon on 2025-02-05.
//

import SwiftUI

/*** Player profile */
struct CoachPlayerProfileView: View {
    @State var player: Player
    let genders = ["Female", "Male", "Other"]
    
    var body: some View {
        NavigationStack {
            
            VStack{
                // profile picture
                /*if let selectedImage = inputImage {
                    Image(uiImage: selectedImage).profileImageStyle()
                } else {
                    profile.defaultProfilePicture
                        .profileImageStyle()
                        .onTapGesture {
                            showImagePicker = true
                        }
                    //.onChange(of: inputImage) {_ in loadImage()}
                        .sheet(isPresented: $showImagePicker) {
                            ImagePicker(image: $inputImage)
                        }
                }*/
                
                // Header
                VStack {
                    Image(systemName: "person.crop.circle").resizable().frame(width: 80, height: 80).foregroundStyle(.gray)
                        .clipShape(Circle())
                        .clipped()
                        .overlay(){
                            ZStack{
                               
                                // border
                                RoundedRectangle(cornerRadius: 100).stroke(.white, lineWidth: 4)
                            }
                        }
                        
                    Text(player.name).font(.title)
                    Text("# \(player.jersey)").font(.subheadline)
                    Text(player.email).font(.subheadline).foregroundStyle(.secondary).padding(.bottom)
                    
                }
                
                // Player information
                List {
                    Section {
                        HStack {
                            Text("Date of birth")
                            Spacer()
                            Text("\(player.dob.formatted(.dateTime.year().month(.twoDigits).day()))").foregroundStyle(.secondary)
                        }.disabled(true)
                        
                        HStack {
                            Text("Gender")
                            Spacer()
                            switch player.gender {
                                case 0: Text("Female").foregroundStyle(.secondary)
                                case 1: Text("Male").foregroundStyle(.secondary)
                                case 2: Text("Other").foregroundStyle(.secondary)
                                default: Text("Unknown").foregroundStyle(.secondary)
                            }
                        }.disabled(true)
                        
                        
                    }
                    
                    Section (header: Text("Guardian Information")) {
                        HStack {
                            Text("Name")
                            Spacer()
                            Text(player.guardianName).foregroundStyle(.secondary)
                        }.disabled(true)
                        
                        HStack {
                            Text("Email")
                            Spacer()
                            Text(player.guardianEmail).foregroundStyle(.secondary)
                        }.disabled(true)
                        
                        HStack {
                            Text("Phone")
                            Spacer()
                            Text(player.guardianPhone).foregroundStyle(.secondary)
                        }.disabled(true)
                       
                    }
                    
                    // Feedback section
                    Section (header: Text("Feedback")) {
                        HStack (alignment: .center) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 110, height: 60)
                                .cornerRadius(10)
                            
                            VStack {
                                Text("Game A vs Y").font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                Text("Key moment #2").font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                Text("mm/dd/yyyy, hh:mm:ss").font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        HStack (alignment: .center) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 110, height: 60)
                                .cornerRadius(10)
                            
                            VStack {
                                Text("Game A vs Y").font(.headline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                Text("Key moment #1").font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                                Text("mm/dd/yyyy, hh:mm:ss").font(.subheadline).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                }
            }
            
        }
    }
}

#Preview {
    CoachPlayerProfileView(player: .init(name: "Mel Rochon", dob: Date(), jersey: 34, gender: 0, email: "mroch@uottawa.ca", profilePicture: nil, guardianName: "Jane Doe", guardianEmail: "jane@g.com", guardianPhone: "613-098-9999"))
}
