//
//  LocationView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-06.
//

import SwiftUI
import MapKit

struct LocationView: View {
    @Binding var location: LocationResult?  // Bind the selected location back to the parent view
    @State var locationSearchService = LocationSearchService()
    
    // Set the environment to retrieve the location entered by the user
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationStack {
            VStack {
                    if (locationSearchService.results.isEmpty) {
                        if let location = location {
                            VStack(alignment: .center) {
                                Text("Selected Location").font(.title3).bold()
                                Text(" \(location.title) \(location.subtitle)").font(.subheadline).multilineTextAlignment(.center).padding(.horizontal)
                                
                                Button("Open in maps") {
                                    var subtitle = location.subtitle
                                    if (subtitle == "Search Nearby") {
                                        if let url = URL(string: "maps://?q=\(location.title)") {
                                            if UIApplication.shared.canOpenURL(url) {
                                                UIApplication.shared.open(url)
                                            } else {
                                                print("Could not open Maps URL")
                                            }
                                        }
                                        subtitle = ""
                                    } else {
                                        if let url = URL(string: "maps://?address=\(location.title) \(subtitle)") {
                                            if UIApplication.shared.canOpenURL(url) {
                                                UIApplication.shared.open(url)
                                            } else {
                                                print("Could not open Maps URL")
                                            }
                                        }
                                    }
                                }
                                
                            }
                            
//                            HStack(alignment: .bottom) {
//                                Button("Open in maps"){
//                                    
//                                }.buttonStyle(.borderedProminent)
//                            }
                        } else {
                            ContentUnavailableView("No Results", systemImage: "questionmark.square.dashed")
                        }
                    } else {
                        List(locationSearchService.results, id: \.id) { result in
                            Button{
                                location = result
                                
                                // Fetch full details (address and coordinates)
                                locationSearchService.resolveFullDetails(for: result)
                                print("Selected Location: \(result)")
                                print("full address: \(result.title) \(result.subtitle)")
                                
                                dismissView() // go back to the game form
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(result.title)
                                    Text(result.subtitle)
                                        .font(.caption).foregroundStyle(.secondary)
                                }.foregroundColor(Color.black)
                            }
                            
                        }
                    }
                
            }.searchable(text: $locationSearchService.query, prompt: "Search a location")
                .navigationTitle("Game Location")
                .navigationBarTitleDisplayMode(.inline)
                .onChange(of: locationSearchService.query) { newQuery in
                    if newQuery.isEmpty {
                        // Handle cancel action (query cleared)
                        handleSearchCancel()
                    }
                }
        }
    }
    
    // Action to handle when search is canceled (query cleared)
    func handleSearchCancel() {
        // Reset the search service results or any other state
        locationSearchService.results = []
        location = nil
        print("Search canceled. Resetting results.")
    }
    
    func dismissView() {
        self.presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    LocationView(location: .constant(nil))
}
