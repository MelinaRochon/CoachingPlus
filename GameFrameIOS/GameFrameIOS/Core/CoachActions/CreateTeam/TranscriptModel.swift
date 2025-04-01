//
//  TranscriptModel.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-31.
//

import Foundation

@MainActor
final class TranscriptModel: ObservableObject {
    
    
    func getUser() async throws -> DBUser? {
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        
        return try await UserManager.shared.getUser(userId: authUser.uid)
    }
    
    func getAllTranscriptsAndKeyMoments(gameId: String, teamDocId: String) async throws -> ([keyMomentTranscript]?, [keyMomentTranscript]?) {
        do {
                        
            // Get all the transcripts from the database
            guard let transcripts = try await TranscriptManager.shared.getAllTranscriptsWithDocId(teamDocId: teamDocId, gameDocId: gameId) else {
                print("No transcripts found") // TO DO - This is not an error because the game doesn't need to have a transcript (e.g. when it is being created -> no transcript)
                return (nil, nil)
            }
            
            guard let user = try await getUser() else {
                print("Could not get user. Aborting..")
                return (nil, nil)
            }
            
            // transcripts were fround in the database. Get the key moments associated to each
            var allRecordings: [keyMomentTranscript] = []
            var allKeyMoments: [keyMomentTranscript] = []

            for transcript in transcripts {
                let keyMomentDocId = transcript.keyMomentId // get the key moment document id to be fetched
                
                // Get all the key moments from the database
                guard let keyMoment = try await KeyMomentManager.shared.getKeyMomentWithDocId(teamDocId: teamDocId, gameDocId: gameId, keyMomentDocId: keyMomentDocId) else {
                    print("No key moment found. Aborting..")
                    return (nil, nil)
                }
                
                // get the length of the arrays to set the id of the element of the list
                let recordingsLength = allRecordings.count
                let keyMomentsLength = allKeyMoments.count
                
                if let userId = user.userId {
                    if user.userType == "Player" {
                        // Only keep key moments that are associated to the player
                        
                        if let feedbackFor = keyMoment.feedbackFor {
                            if feedbackFor.contains(userId) {
                                // Only show feedback for the player, not everyone it is addressed to
                                // Reason: Privacy reasons!
                                let tmpPlayer = try await getAllPlayersInfo(feedbackFor: [userId])
                                let newKeyMomTranscript = keyMomentTranscript(id: recordingsLength, keyMomentId: transcript.keyMomentId, transcriptId: transcript.transcriptId, transcript: transcript.transcript, frameStart: keyMoment.frameStart, frameEnd: keyMoment.frameEnd, feedbackFor: tmpPlayer)
                                
                                // Adding new element to the transcripts array
                                allRecordings.append(newKeyMomTranscript)
                                
                                if keyMoment.fullGameId != nil {
                                    let newKeyMomTranscript = keyMomentTranscript(id: keyMomentsLength, keyMomentId: transcript.keyMomentId, transcriptId: transcript.transcriptId, transcript: transcript.transcript, frameStart: keyMoment.frameStart, frameEnd: keyMoment.frameEnd, feedbackFor: tmpPlayer)
                                    
                                    // Adding new element to the transcripts array
                                    allKeyMoments.append(newKeyMomTranscript)
                                }
                            }
                        }
                    } else {
                        
                        let tmpPlayer = try await getAllPlayersInfo(feedbackFor: keyMoment.feedbackFor)
                        
                        let newKeyMomTranscript = keyMomentTranscript(id: recordingsLength, keyMomentId: transcript.keyMomentId, transcriptId: transcript.transcriptId, transcript: transcript.transcript, frameStart: keyMoment.frameStart, frameEnd: keyMoment.frameEnd, feedbackFor: tmpPlayer)
                        
                        // Adding new element to the array
                        allRecordings.append(newKeyMomTranscript)
                        
                        if keyMoment.fullGameId != nil {
                            let newKeyMomTranscript = keyMomentTranscript(id: keyMomentsLength, keyMomentId: transcript.keyMomentId, transcriptId: transcript.transcriptId, transcript: transcript.transcript, frameStart: keyMoment.frameStart, frameEnd: keyMoment.frameEnd, feedbackFor: tmpPlayer)
                            
                            // Adding new element to the transcripts array
                            allKeyMoments.append(newKeyMomTranscript)
                        }
                    }
                }
            }
            
            // filter the transcripts and key moments
            let sortedTranscripts = allRecordings.sorted(by: { $0.frameStart < $1.frameStart})
            let sortedKeyMoments = allKeyMoments.sorted(by: { $0.frameStart < $1.frameStart})
            
            return (sortedTranscripts, sortedKeyMoments)
        } catch {
            print("Error when loading the recordings from the database. Error: \(error)")
            return (nil, nil)
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
    
    func getFeebackFor(feedbackFor: [String]) async throws -> [PlayerNameAndPhoto]? {
        // Find the players in the feedbackFor array (player_id) and return their names
        if !feedbackFor.isEmpty {
            
            var tmpPlayers: [PlayerNameAndPhoto] = []
            // There are players associated to the feedback
            for feedbackId in feedbackFor {
                
                // get the player
                guard let player = try await PlayerManager.shared.getPlayer(playerId: feedbackId) else {
                    print("No player found with this player id. Aborting..")
                    return nil
                }
                
                guard let user = try await UserManager.shared.getUser(userId: player.playerId!) else {
                    print("No user found with this player id. Aborting..")
                    return nil
                }
                
                let playerName = (user.firstName + " " + user.lastName)
                
                // create a new array to store the players
                let newPlayer = PlayerNameAndPhoto(playerId: player.playerId!, name: playerName, photoURL: nil)
                tmpPlayers.append(newPlayer)
            }
            
            return tmpPlayers
        }
        
        return nil
    }
}
