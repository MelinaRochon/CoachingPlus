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
    
    @Published var teamId = ""
    @Published var title = ""
    @Published var duration: Int = 0 // in seconds
    @Published var location: LocationResult?
    @Published var scheduledTimeReminder: Int = 0 // in minutes
    @Published var startTime: Date = Date() //? = nil
    @Published var timeBeforeFeedback: Int = 0 // in seconds
    @Published var timeAfterFeedback: Int = 0 // in seconds
    @Published var recordingReminder: Bool = false
    
    @Published var teamNames: [GetTeam] = []
    
    /** Loads all team names that the coach is coaching. Function only called if the teamId isn't passed as an
     argument when calling the addGameView page */
    func loadTeamNames() async throws {
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        teamNames = try await CoachManager.shared.loadTeamsCoaching(coachId: authUser.uid)
    }
    
    /** POST - Adds a new game to the database */
    func addNewGame() async throws {
        
        // finalise the location
        let finalLocation = (location!.title + " " + location!.subtitle)
        
        print("finalLocation = \(finalLocation)")
        // create a DTO object to be sent to the database
        let gameDTO = GameDTO(title: title, duration: duration, location: finalLocation, scheduledTimeReminder: scheduledTimeReminder, startTime: startTime, timeBeforeFeedback: timeBeforeFeedback, timeAfterFeedback: timeAfterFeedback, recordingReminder: recordingReminder, teamId: teamId)

        // Add game to the database
        try await GameManager.shared.addNewGame(gameDTO: gameDTO)
    }
    
    func test() {
        print("title: \(title), duration: \(duration), location: \(location), scheduledTimeReminder: \(scheduledTimeReminder), starttime: \(startTime), timeBeforeFeedback: \(timeBeforeFeedback), timeAfterFeedback: \(timeAfterFeedback), recordingReminder: \(recordingReminder)")
    }
}
