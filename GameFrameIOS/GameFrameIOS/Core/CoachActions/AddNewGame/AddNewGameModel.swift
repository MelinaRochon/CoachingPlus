//
//  AddNewGameModel.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-07.
//

import Foundation

struct GetTeam {
    var teamId: String
    var name: String
}

@MainActor
final class AddNewGameModel: ObservableObject {
    @Published var game: DBGame? = nil // game information
    
    @Published var title = ""
    @Published var duration: Int = 0 // in seconds
    @Published var location: LocationResult?
    @Published var scheduledTimeReminder: Int = 0 // in minutes
    @Published var startTime: Date = Date() //? = nil
    @Published var timeBeforeFeedback: Int = 0 // in seconds
    @Published var timeAfterFeedback: Int = 0 // in seconds
    @Published var recordingReminder: Bool = false
    
    @Published var teamNames: [GetTeam] = []
//    @Published var selectedTeamName: String?
    
//    let gameId: String
//    let title: String
//    let duration: Date?
//    let location: String?
//    let scheduledTime: Date?
//    let startTime: Date?
//    let timeBeforeFeedback: Date
//    let timeAfterFeedback: Date
//    let recordingReminder: Bool
//    let teamId: String
    
    /** Loads all team names that the coach is coaching. Function only called if the teamId isn't passed as an
     argument when calling the addGameView page */
    func loadTeamNames() async throws {
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        
        teamNames = try await CoachManager.shared.loadTeamsCoaching(coachId: authUser.uid)

    }
    
    func addNewGame() async throws {
        //guard let
        guard let game else { return }
        
        // Add game to the database
        try await GameManager.shared.addNewGame(game: game)
        
    }
    
    func test() {
        print("title: \(title), duration: \(duration), location: \(location), scheduledTimeReminder: \(scheduledTimeReminder), starttime: \(startTime), timeBeforeFeedback: \(timeBeforeFeedback), timeAfterFeedback: \(timeAfterFeedback), recordingReminder: \(recordingReminder)")
    }
}
