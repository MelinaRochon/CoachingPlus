//
//  TranscriptViewModel.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-20.
//

import Foundation

struct PlayerNameAndPhoto {
    let playerId: String
    let name: String
    let photoURL: URL?
}

@MainActor
final class TranscriptViewModel: ObservableObject {
    
    @Published var team: DBTeam?
    @Published var game: DBGame?
    // TO DO - Will need to add the key moments db
    
    @Published var recordings: [keyMomentTranscript] = [];
    @Published var keyMoments: [keyMomentTranscript] = [];

    @Published var feedbackFor: [PlayerNameAndPhoto]? = nil
    @Published var gameStartTime: Date? = nil
    
    func loadAllTranscripts(gameId: String, teamDocId: String) async throws {
        do {
                        
            // Get all the transcripts from the database
            guard let transcripts = try await TranscriptManager.shared.getAllTranscriptsWithDocId(teamDocId: teamDocId, gameDocId: gameId) else {
                print("No transcripts found") // TO DO - This is not an error because the game doesn't need to have a transcript (e.g. when it is being created -> no transcript)
                return
            }
            
            // transcripts were fround in the database. Get the key moments associated to each
            var allRecordings: [keyMomentTranscript] = []
            for transcript in transcripts {
                let keyMomentDocId = transcript.keyMomentId // get the key moment document id to be fetched
                
                // Get all the key moments from the database
                guard let keyMoment = try await KeyMomentManager.shared.getKeyMomentWithDocId(teamDocId: teamDocId, gameDocId: gameId, keyMomentDocId: keyMomentDocId) else {
                    print("No key moment found. Aborting..")
                    return
                }
                // get the length of the array to set the id of the element of the list
                let recordingsLength = allRecordings.count
                let tmpPlayer = try await getAllPlayersInfo(feedbackFor: keyMoment.feedbackFor)

                let keyMomentTranscript = keyMomentTranscript(id: recordingsLength, transcript: transcript.transcript, frameStart: keyMoment.frameStart, frameEnd: keyMoment.frameEnd, feedbackFor: tmpPlayer)
                
                // Adding new element to the array
                allRecordings.append(keyMomentTranscript)
            }
            
            // filter the games
            let tmpAllRecordings: [keyMomentTranscript] = []
            
            let sortedRecordings = allRecordings.sorted { recording1, recording2 in
                let frameStart1 = recording1.frameStart
                let frameStart2 = recording2.frameStart
                return frameStart1 < frameStart2
            }
            
            self.recordings = sortedRecordings
            
        } catch {
            print("Error when loading the recordings from the database. Error: \(error)")
            return
        }
    }
    
    func getGameStartTime(gameId: String, teamDocId: String) async throws {
        do {
            guard let game = try await GameManager.shared.getGameWithDocId(gameDocId: gameId, teamDocId: teamDocId) else {
                print("Could not get the game information.")
                return
            }
            
            self.gameStartTime = game.startTime
            
        } catch {
            print("Could not get the game start time. Aborting.")
            return
        }
    }
    
    func loadFirstThreeTranscripts(gameId: String, teamDocId: String) async throws {
        // For now, take a games array
        do {
                        
            // Get all the transcripts from the database
            guard let transcripts = try await TranscriptManager.shared.getAllTranscriptsWithDocId(teamDocId: teamDocId, gameDocId: gameId) else {
                print("No transcripts found") // TO DO - This is not an error because the game doesn't need to have a transcript (e.g. when it is being created -> no transcript)
                return
            }
            
            // transcripts were fround in the database. Get the key moments associated to each
            var allRecordings: [keyMomentTranscript] = []
            for transcript in transcripts {
                let keyMomentDocId = transcript.keyMomentId // get the key moment document id to be fetched
                
                // Get all the key moments from the database
                guard let keyMoment = try await KeyMomentManager.shared.getKeyMomentWithDocId(teamDocId: teamDocId, gameDocId: gameId, keyMomentDocId: keyMomentDocId) else {
                    print("No key moment found. Aborting..")
                    return
                }
                // get the length of the array to set the id of the element of the list
                let recordingsLength = allRecordings.count
                let tmpPlayer = try await getAllPlayersInfo(feedbackFor: keyMoment.feedbackFor)

                let keyMomentTranscript = keyMomentTranscript(id: recordingsLength, transcript: transcript.transcript, frameStart: keyMoment.frameStart, frameEnd: keyMoment.frameEnd, feedbackFor: tmpPlayer)
                
                // Adding new element to the array
                allRecordings.append(keyMomentTranscript)
            }
                        
            self.recordings = Array(allRecordings.sorted(by: { $0.frameStart < $1.frameStart }).prefix(3))

        } catch {
            print("Error when loading the recordings from the database. Error: \(error)")
            return
        }
    }

    func loadFirstThreeKeyMoments(gameId: String, teamDocId: String) async throws {
        // For now, take a games array
        do {
                        
            // Get all the transcripts from the database
            guard let transcripts = try await TranscriptManager.shared.getAllTranscriptsWithDocId(teamDocId: teamDocId, gameDocId: gameId) else {
                print("No transcripts found") // TO DO - This is not an error because the game doesn't need to have a transcript (e.g. when it is being created -> no transcript)
                return
            }
            
            // transcripts were fround in the database. Get the key moments associated to each
            var allRecordings: [keyMomentTranscript] = []
            for transcript in transcripts {
                let keyMomentDocId = transcript.keyMomentId // get the key moment document id to be fetched
                
                // Get all the key moments from the database
                guard let keyMoment = try await KeyMomentManager.shared.getKeyMomentWithDocId(teamDocId: teamDocId, gameDocId: gameId, keyMomentDocId: keyMomentDocId) else {
                    print("No key moment found. Aborting..")
                    return
                }
                
                if keyMoment.fullGameId != nil {
                    
                    let tmpPlayer = try await getAllPlayersInfo(feedbackFor: keyMoment.feedbackFor)

                    // get the length of the array to set the id of the element of the list
                    let recordingsLength = allRecordings.count
                    let keyMomentTranscript = keyMomentTranscript(id: recordingsLength, transcript: transcript.transcript, frameStart: keyMoment.frameStart, frameEnd: keyMoment.frameEnd, feedbackFor: tmpPlayer)
                    
                    // Adding new element to the array
                    allRecordings.append(keyMomentTranscript)
                } else {
                    print("")
                }
            }
            
            self.keyMoments = Array(allRecordings.sorted(by: { $0.frameStart < $1.frameStart }).prefix(3))

        } catch {
            print("Error when loading the recordings from the database. Error: \(error)")
            return
        }
    }

    func loadGameDetails(gameId: String, teamDocId: String) async throws {
        // Get the team data
        let team = try await TeamManager.shared.getTeamWithDocId(docId: teamDocId);
        
        self.team = team
        
        // Get the game's data
        guard let tmpGame = try await GameManager.shared.getGame(gameId: gameId, teamId: team.teamId) else {
            print("Game not found or nil")
            return
        }
        
        self.game = tmpGame
        self.gameStartTime = tmpGame.startTime

    }
    
    func getFeebackFor(feedbackFor: [String]) async throws {
        // Find the players in the feedbackFor array (player_id) and return their names
        if !feedbackFor.isEmpty {
            
            var tmpPlayers: [PlayerNameAndPhoto] = []
            // There are players associated to the feedback
            for feedbackId in feedbackFor {
                
                // get the player
                guard let player = try await PlayerManager.shared.getPlayer(playerId: feedbackId) else {
                    print("No player found with this player id. Aborting..")
                    return
                }
                
                guard let user = try await UserManager.shared.getUser(userId: player.playerId!) else {
                    print("No user found with this player id. Aborting..")
                    return
                }
                
                let playerName = (user.firstName + " " + user.lastName)
                
                // create a new array to store the players
                let newPlayer = PlayerNameAndPhoto(playerId: player.playerId!, name: playerName, photoURL: nil)
                tmpPlayers.append(newPlayer)
            }
            
            self.feedbackFor = tmpPlayers
        }
    }
    
    func getAllPlayersInfo (feedbackFor: [String]?) async throws -> [PlayerTranscriptInfo] {
        var tmpPlayer: [PlayerTranscriptInfo] = []
        if let feedbackFor = feedbackFor {
            for playerId in feedbackFor {
                let player = try await loadPlayerInfo(playerId: playerId)!;
                
                tmpPlayer.append(player)
            }
        }
        return tmpPlayer
    }
    func loadPlayerInfo(playerId: String) async throws -> PlayerTranscriptInfo? {
        // get the user info
        guard let user = try await UserManager.shared.getUser(userId: playerId) else {
            print("no user found. abort")
            return nil
        }
        
        guard let player = try await PlayerManager.shared.getPlayer(playerId: playerId) else {
            print("no player found. abprt")
            return nil
        }
        
        // create an object to store the player's info
        let playerObject = PlayerTranscriptInfo(playerId: playerId, firstName: user.firstName, lastName: user.lastName, nickname: player.nickName, jersey: player.jerseyNum)
        
        return playerObject
    }
}
