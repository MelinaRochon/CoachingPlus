//
//  CreateTeamViewModel.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-03-10.
//

import Foundation
@MainActor

final class CreateTeamViewModel: ObservableObject {
    @Published var name = ""
    @Published var sport = ""
    @Published var logoURL = ""
    @Published var color = ""
    @Published var gender = ""
    @Published var ageGrp = ""
    @Published var alertMessage = ""
    @Published var showAlert = false
    @Published var isLoading = false
    
    func createTeam(auth: AuthDataResultModel) {
        isLoading = true
        
        let newTeam = DBTeam(
            teamId: UUID().uuidString,
            name: name,
            sport: sport,
            logoUrl: logoURL.isEmpty ? nil : logoURL,
            colour: color,
            gender: gender,
            ageGrp: ageGrp,
            accessCode: nil,  // Optional access code for joining the team
            coaches: [auth.uid],  // The coach creating the team
            players: []
        )

        Task {
            do {
                try await TeamManager.shared.createNewTeam(auth: auth, team: newTeam)
                DispatchQueue.main.async {
                    self.alertMessage = "Team created successfully!"
                    self.resetForm()
                    self.showAlert = true
                }
            } catch {
                DispatchQueue.main.async {
                    self.alertMessage = "Error: \(error.localizedDescription)"
                    self.showAlert = true
                }
            }
            self.isLoading = false
        }
    }
    
    private func resetForm() {
            name = ""
            sport = ""
            logoURL = ""
            color = ""
            gender = ""
            ageGrp = ""
        }
}
