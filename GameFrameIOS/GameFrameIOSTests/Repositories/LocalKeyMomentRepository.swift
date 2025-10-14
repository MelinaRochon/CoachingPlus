//
//  LocalKeyMomentRepository.swift
//  GameFrameIOSTests
//
//  Created by Mélina Rochon on 2025-10-14.
//

import Foundation
@testable import GameFrameIOS

final class LocalKeyMomentRepository: KeyMomentRepository {
    
    private var keyMoments: [DBKeyMoment] = []
    private var transcripts: [DBTranscript] = []
    
    /// Retrieves a specific key moment by its ID for the given team and game.
    /// - Parameters:
    ///   - teamId: The unique identifier of the team.
    ///   - gameId: The unique identifier of the game.
    ///   - keyMomentDocId: The Firestore document ID of the key moment to retrieve.
    /// - Returns: A `DBKeyMoment` object if found, otherwise `nil`.
    /// - Throws: An error if retrieval fails.
    func getKeyMoment(teamId: String, gameId: String, keyMomentDocId: String) async throws -> DBKeyMoment? {
        return keyMoments.first { $0.gameId == gameId && $0.keyMomentId == keyMomentDocId }
    }
    
    /// Assigns a player to all key moments for the specified team and game.
    /// - Parameters:
    ///   - teamDocId: The Firestore document ID of the team.
    ///   - gameId: The Firestore document ID of the game.
    ///   - playersCount: The total number of players on the team.
    ///   - playerId: The Firestore document ID of the player being assigned.
    /// - Throws: An error if the assignment process fails.
    func assignPlayerToKeyMomentsForEntireTeam(teamDocId: String, gameId: String, playersCount: Int, playerId: String) async throws {
        var keyMoments = keyMoments.filter { $0.gameId == gameId && $0.feedbackFor?.count ?? 0 == playersCount }
        
        guard !keyMoments.isEmpty else {
            throw NSError(domain: "KeyMomentRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "No key moments found."])
        }
        
        for (index, moment) in keyMoments.enumerated() {
            var tmpKeyMoment = moment
            if !tmpKeyMoment.feedbackFor!.isEmpty {
                tmpKeyMoment.feedbackFor!.append(playerId)
            }
            
            keyMoments[index] = tmpKeyMoment
        }
    }
    
    func getKeyMomentWithDocId(teamDocId: String, gameDocId: String, keyMomentDocId: String) async throws -> DBKeyMoment? {
        return keyMoments.first { $0.gameId == gameDocId && $0.keyMomentId == keyMomentDocId }
    }
    
    func getAudioUrl(teamDocId: String, gameDocId: String, keyMomentId: String) async throws -> String? {
        return keyMoments.first(where: { $0.gameId == gameDocId && $0.keyMomentId == keyMomentId })?.audioUrl ?? nil
    }
    
    func getAllKeyMoments(teamId: String, gameId: String) async throws -> [DBKeyMoment]? {
        return keyMoments.filter { $0.gameId == gameId }
    }
    
    func getAllKeyMomentsWithTeamDocId(teamDocId: String, gameId: String) async throws -> [DBKeyMoment]? {
        return keyMoments.filter { $0.gameId == gameId }
    }
    
    func addNewKeyMoment(teamId: String, keyMomentDTO: KeyMomentDTO) async throws -> String? {
        let id = UUID().uuidString
        let keyMoment = DBKeyMoment(keyMomentId: id, keyMomentDTO: keyMomentDTO)
        keyMoments.append(keyMoment)
        return id
    }
    
    func removeKeyMoment(teamId: String, gameId: String, keyMomentId: String) async throws {
        guard let index = keyMoments.firstIndex(where: { $0.gameId == gameId && $0.keyMomentId == keyMomentId }) else {
            print("Key moment not found with id: \(keyMomentId)")
            return
        }
        
        // Remove the key moment from the local list
        keyMoments.remove(at: index)
    }
    
    func addPlayerToFeedbackFor(teamDocId: String, gameId: String, keyMomentId: String, newPlayerId: String) async throws {
        guard let index = keyMoments.firstIndex(where: { $0.gameId == gameId && $0.keyMomentId == keyMomentId }) else {
            print("Key moment not found with id: \(keyMomentId)")
            return
        }
        
        var keyMoment = keyMoments[index]
        
        // Add the player to feedbackFor
        if !keyMoment.feedbackFor!.contains(newPlayerId) {
            keyMoment.feedbackFor?.append(newPlayerId)
            keyMoments[index] = keyMoment
        } else {
            print("Player already assigned to this key moment \(keyMomentId)")
        }
    }
    
    func deleteAllKeyMoments(teamDocId: String, gameId: String) async throws {
        var keyMoments = keyMoments.filter( {$0.gameId == gameId} )
        
        if keyMoments.isEmpty {
            print("Could not find any key moments to be deleted for gameId: \(gameId)")
            return
        }
        
        // Remove all key moments from the local list
        keyMoments.removeAll()
    }
    
    func updateFeedbackFor(transcriptId: String, gameId: String, teamId: String, teamDocId: String, feedbackFor: [PlayerNameAndPhoto]) async throws {
        guard var transcript = transcripts.first(where: { $0.transcriptId == transcriptId && $0.gameId == gameId }) else {
            print("Transcript not found with id: \(transcriptId)")
            return
        }
                
        guard var keyMomentsToUpdate = keyMoments.first(where: { $0.gameId == gameId && $0.keyMomentId == transcript.keyMomentId }) else {
            print("Key moment not found with id: \(transcript.keyMomentId)")
            return
        }
        for player in feedbackFor {
            keyMomentsToUpdate.feedbackFor?.append(player.playerId)
        }
    }
}
