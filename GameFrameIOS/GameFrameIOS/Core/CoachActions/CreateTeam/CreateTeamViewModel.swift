//
//  CreateTeamViewModel.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-03-10.
//

import Foundation
import SwiftUI

@MainActor
final class CreateTeamViewModel: ObservableObject {
    @Published var team: DBTeam? = nil
    
    @Published var name = ""
    @Published var sport = ""
    @Published var logoURL = ""
    @Published var colourHex: String = "#0000FF" // Default to blue
    @Published var gender = ""
    @Published var ageGrp = ""
    @Published var alertMessage = ""
    @Published var showAlert = false
    //@Published var isLoading = false
    
    // Convert HEX to SwiftUI Color
        var colour: Color {
            return Color(hex: colourHex) ?? .blue
        }
    
    func createTeam() async throws {
        do {
            print("HEYY")
            let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
            print(authUser)
            print("OKAYY")
            let coachId = authUser.uid
            print("WOO")
            let newTeam = DBTeam(
                teamId: UUID().uuidString,
                name: name,
                sport: sport,
                logoUrl: logoURL.isEmpty ? nil : logoURL,
                colour: colourHex,
                gender: gender,
                ageGrp: ageGrp,
                accessCode: nil,  // Optional access code for joining the team
                coaches: [coachId],  // The coach creating the team
                players: []
            )
            print("DISTHEONE")
            
            try await TeamManager.shared.createNewTeam(coachId: coachId, team: newTeam)
            print("NAHHH")
        } catch {
            print("Failed to create team: \(error.localizedDescription)")
            alertMessage = "Error: \(error.localizedDescription)"
            showAlert = true
        }
    }
    
    // Update HEX from ColorPicker
    func updateColour(from color: Color) {
        colourHex = color.toHex() ?? "#000000"
    }
    
    func test(){
        print("name: \(name), sport: \(sport), logoUrl: \(logoURL), colour: \(colour), gender: \(gender), ageGrp: \(ageGrp)")
    }
}
