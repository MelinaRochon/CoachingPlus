//
//  LocalKeyMomentRepository.swift
//  GameFrameIOSTests
//
//  Created by Mélina Rochon on 2025-10-14.
//

import Foundation

public final class LocalKeyMomentRepository: KeyMomentRepository {
    
    private var keyMoments: [DBKeyMoment] = []
    private var transcripts: [DBTranscript] = []

    public init(keyMoments: [DBKeyMoment]? = nil) {
        // If no teams provided, fallback to default JSON
        self.keyMoments = keyMoments ?? TestDataLoader.load("TestKeyMoments", as: [DBKeyMoment].self)
    }
    
    #if DEBUG
    /// Test-only: seed transcripts when a test needs them.
    public func seedTranscripts(_ items: [DBTranscript]) {
        self.transcripts = items
    }
    #endif

    /// Retrieves a specific key moment by its ID for the given team and game.
    /// - Parameters:
    ///   - teamId: The unique identifier of the team.
    ///   - gameId: The unique identifier of the game.
    ///   - keyMomentDocId: The Firestore document ID of the key moment to retrieve.
    /// - Returns: A `DBKeyMoment` object if found, otherwise `nil`.
    /// - Throws: An error if retrieval fails.
    public func getKeyMoment(teamId: String, gameId: String, keyMomentDocId: String) async throws -> DBKeyMoment? {
//        return keyMoments.first { $0.gameId == gameId && $0.keyMomentId == keyMomentDocId }
        guard let keyMoment = keyMoments.first (where: { $0.gameId == gameId && $0.keyMomentId == keyMomentDocId }) else {
            throw KeyMomentError.keyMomentNotFound
        }
        return keyMoment
    }
    
    /// Assigns a player to all key moments for the specified team and game.
    /// - Parameters:
    ///   - teamDocId: The Firestore document ID of the team.
    ///   - gameId: The Firestore document ID of the game.
    ///   - playersCount: The total number of players on the team.
    ///   - playerId: The Firestore document ID of the player being assigned.
    /// - Throws: An error if the assignment process fails.
    public func assignPlayerToKeyMomentsForEntireTeam(teamDocId: String, gameId: String, playersCount: Int, playerId: String) async throws {
        // Find the indices to mutate in-place
        let targetIndices = keyMoments.indices.filter {
            keyMoments[$0].gameId == gameId && (keyMoments[$0].feedbackFor?.count ?? 0) == playersCount
        }

        guard !targetIndices.isEmpty else {
            throw KeyMomentError.keyMomentNotFound
//            throw NSError(domain: "KeyMomentRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "No key moments found."])
        }

        for idx in targetIndices {
            var km = keyMoments[idx]
            var feedback = km.feedbackFor ?? []
            if !feedback.contains(playerId) {
                feedback.append(playerId)
                km.feedbackFor = feedback
                keyMoments[idx] = km
            }
        }
    }
    
    public func getKeyMomentWithDocId(teamDocId: String, gameDocId: String, keyMomentDocId: String) async throws -> DBKeyMoment? {
//        return keyMoments.first { $0.gameId == gameDocId && $0.keyMomentId == keyMomentDocId }
        guard let keyMoment = keyMoments.first (where: { $0.gameId == gameDocId && $0.keyMomentId == keyMomentDocId }) else {
            throw KeyMomentError.keyMomentNotFound
        }
        return keyMoment
    }
    
    public func getAudioUrl(teamDocId: String, gameDocId: String, keyMomentId: String) async throws -> String? {
        return keyMoments.first(where: { $0.gameId == gameDocId && $0.keyMomentId == keyMomentId })?.audioUrl ?? nil
    }
    
    public func getAllKeyMoments(teamId: String, gameId: String) async throws -> [DBKeyMoment]? {
        return keyMoments.filter { $0.gameId == gameId }
    }
    
    public func getAllKeyMomentsWithTeamDocId(teamDocId: String, gameId: String) async throws -> [DBKeyMoment]? {
        return keyMoments.filter { $0.gameId == gameId }
    }
    
    public func addNewKeyMoment(teamId: String, keyMomentDTO: KeyMomentDTO) async throws -> String? {
        let id = UUID().uuidString
        let keyMoment = DBKeyMoment(keyMomentId: id, keyMomentDTO: keyMomentDTO)
        keyMoments.append(keyMoment)
        return id
    }
    
    public func removeKeyMoment(teamId: String, gameId: String, keyMomentId: String) async throws {
        guard let index = keyMoments.firstIndex(where: { $0.gameId == gameId && $0.keyMomentId == keyMomentId }) else {
            print("Key moment not found with id: \(keyMomentId)")
            throw KeyMomentError.keyMomentNotFound
        }
        
        // Remove the key moment from the local list
        keyMoments.remove(at: index)
    }
    
    public func addPlayerToFeedbackFor(teamDocId: String, gameId: String, keyMomentId: String, newPlayerId: String) async throws {
        guard let index = keyMoments.firstIndex(where: { $0.gameId == gameId && $0.keyMomentId == keyMomentId }) else {
            print("Key moment not found with id: \(keyMomentId)")
            throw KeyMomentError.keyMomentNotFound
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
    
    public func deleteAllKeyMoments(teamDocId: String, gameId: String) async throws {
        let before = keyMoments.count

        // remove from the stored array in-place
        keyMoments.removeAll { $0.gameId == gameId /* && $0.teamId == teamDocId (if you have one) */ }

        if before == keyMoments.count {
            print("Could not find any key moments to be deleted for gameId: \(gameId)")
        }
    }
    
    public func updateFeedbackFor(transcriptId: String, gameId: String, teamId: String, teamDocId: String, feedbackFor: [PlayerNameAndPhoto]) async throws {
        // Find the transcript first
            guard let tr = transcripts.first(where: { $0.transcriptId == transcriptId && $0.gameId == gameId }) else {
                print("Transcript not found with id: \(transcriptId)")
                return
            }

            // Find the index of the key moment we need to update
            guard let idx = keyMoments.firstIndex(where: { $0.gameId == gameId && $0.keyMomentId == tr.keyMomentId }) else {
                print("Key moment not found with id: \(tr.keyMomentId)")
                throw KeyMomentError.keyMomentNotFound
            }

            // Copy–modify–write-back
            var km = keyMoments[idx]

            // Start from existing recipients (could be nil)
            var recipients = Set(km.feedbackFor ?? [])

            // Add new players (deduped)
            for p in feedbackFor {
                recipients.insert(p.playerId)
            }

            km.feedbackFor = Array(recipients)

            // Persist the change back into the repository storage
            keyMoments[idx] = km
    }
}
