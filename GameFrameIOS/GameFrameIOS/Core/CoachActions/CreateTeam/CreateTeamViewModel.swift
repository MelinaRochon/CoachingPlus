//
//  CreateTeamViewModel.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-03-10.
//

import Foundation

@MainActor
final class CreateTeamViewModel: ObservableObject {
    @Published var team: DBTeam? = nil
    
    @Published var name = ""
    @Published var sport = ""
    @Published var logoURL = ""
    @Published var colour = ""
    @Published var gender = ""
    @Published var ageGrp = ""
    @Published var alertMessage = ""
    @Published var showAlert = false
    //@Published var isLoading = false
    
    func createTeam(coachId: String) async throws {
        
        let newTeam = DBTeam(
            teamId: UUID().uuidString,
            name: name,
            sport: sport,
            logoUrl: logoURL.isEmpty ? nil : logoURL,
            colour: colour,
            gender: gender,
            ageGrp: ageGrp,
            accessCode: nil,  // Optional access code for joining the team
            coaches: [coachId],  // The coach creating the team
            players: []
            )
            
        try await TeamManager.shared.createNewTeam(coachId: coachId, team: newTeam)
    }
    
    func test(){
        print("name: \(name), sport: \(sport), logoUrl: \(logoURL), colour: \(colour), gender: \(gender), ageGrp: \(ageGrp)")
    }
}
