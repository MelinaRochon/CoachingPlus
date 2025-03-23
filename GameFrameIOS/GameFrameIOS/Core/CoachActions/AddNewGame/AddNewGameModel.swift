//
//  AddNewGameModel.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-07.
//

import Foundation

struct GetTeam: Equatable {
    var teamId: String
    var name: String
    var nickname: String
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
    func addNewGame() async throws -> Bool {
        do {
            // Guards to make sure the new game is valid
            guard !title.isEmpty else {
                print("Title of game cannot be nil.. Aborting.")
                return false
            }
            
            guard duration != 0 else {
                print("No duration was entered. Aborting..")
                return false
            }
            
            let finalLocation: String?;
            if location == nil {
                print("No location entered. Proceeding...")
                finalLocation = nil
            } else {
                // finalise the location
                finalLocation = (location!.title + " " + location!.subtitle)
            }
            print("finalLocation = \(finalLocation)")
            // create a DTO object to be sent to the database
            let gameDTO = GameDTO(title: title, duration: duration, location: finalLocation, scheduledTimeReminder: scheduledTimeReminder, startTime: startTime, timeBeforeFeedback: timeBeforeFeedback, timeAfterFeedback: timeAfterFeedback, recordingReminder: recordingReminder, teamId: teamId)
            
            // Add game to the database
            try await GameManager.shared.addNewGame(gameDTO: gameDTO)
            
            return true
        } catch {
            print("Failed to add a new game: \(error.localizedDescription)")
            return false
        }
    }
    
    func addUnknownGame() async throws -> String? {
        // Add game to the database
        return try await GameManager.shared.addNewUnkownGame(teamId: teamId)
//        if gameId == nil {
//            print("Error when adding a new game. Could not get the gameId. Aborting")
//            return nil
//        }
//        return gameId
    }
    
    func test() {
        print("title: \(title), duration: \(duration), location: \(location), scheduledTimeReminder: \(scheduledTimeReminder), starttime: \(startTime), timeBeforeFeedback: \(timeBeforeFeedback), timeAfterFeedback: \(timeAfterFeedback), recordingReminder: \(recordingReminder)")
    }
}
