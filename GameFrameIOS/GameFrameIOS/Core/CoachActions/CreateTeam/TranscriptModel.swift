//
//  TranscriptModel.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-31.
//

import Foundation
import GameFrameIOSShared

/// **TranscriptModel** is responsible for handling transcript and key moment retrieval for a game.
///
/// ## Responsibilities:
/// - Fetching user details.
/// - Retrieving all transcripts and key moments for a given game.
/// - Filtering and sorting transcripts based on user type (player vs. coach).
/// - Loading player information for transcript feedback.
///
/// This class ensures all operations run on the main actor to prevent concurrency issues in SwiftUI.
@MainActor
final class TranscriptModel: ObservableObject {
    
    /// Holds the app’s shared dependency container, used to access services and repositories.
    private var dependencies: DependencyContainer?

    // MARK: - Dependency Injection
    
    /// Injects the provided `DependencyContainer` into the current context.
    ///
    /// This allows the view, view model, or controller to access shared
    /// dependencies such as managers or repositories from a central container.
    /// Useful for testing, environment configuration (e.g., local vs. Firestore),
    /// or replacing dependencies at runtime.
    func setDependencies(_ dependencies: DependencyContainer) {
        self.dependencies = dependencies
    }

    
    /// Retrieves the authenticated user from the database.
    ///
    /// - Returns: A `DBUser` object representing the authenticated user, or `nil` if not found.
    /// - Throws: An error if authentication fails.
    /// - Throws: An error if authentication fails.
    func getUser() async throws -> DBUser? {
        guard let repo = dependencies else {
            print("Dependencies not set")
            return nil
        }

        let authUser = try repo.authenticationManager.getAuthenticatedUser()
        return try await repo.userManager.getUser(userId: authUser.uid)
    }
    
    /// Retrieves all transcripts and key moments for a specific game.
    ///
    /// - Parameters:
    ///   - gameId: The unique identifier for the game.
    ///   - teamDocId: The unique identifier for the team.
    /// - Returns: A tuple containing two optional arrays:
    ///   - The first array contains key moment transcripts for recorded clips.
    ///   - The second array contains key moments for full-game analysis.
    /// - Throws: An error if the retrieval process fails.
    func getAllTranscripts(gameId: String, teamDocId: String) async throws -> [keyMomentTranscript]? {
        do {
            // Retrieve all transcripts associated with the game.
            guard let transcripts = try await dependencies?.transcriptManager.getAllTranscriptsWithDocId(teamDocId: teamDocId, gameDocId: gameId) else {
                print("No transcripts found") // TO DO - This is not an error because the game doesn't need to have a transcript (e.g. when it is being created -> no transcript)
                return nil
            }

            // Retrieve the authenticated user.
            guard let user = try await getUser() else {
                print("Could not get user. Aborting..")
                return nil
            }
            
            // Retrieve all key moments
            guard let keyMoment = try await dependencies?.keyMomentManager.getAllKeyMomentsWithTeamDocId(teamDocId: teamDocId, gameId: gameId) else {
                print("No key moment found. Aborting..")
                return nil
            }
            
            let keyMomentsDict = Dictionary(uniqueKeysWithValues: keyMoment.map { ($0.keyMomentId, $0) })

            var allUserIds: Set<String> = []
            for km in keyMoment {
                if let feedbackFor = km.feedbackFor {
                    allUserIds.formUnion(feedbackFor)
                }
            }
            
            let allPlayers = try await getAllPlayersInfo(feedbackFor: Array(allUserIds), teamDocId: teamDocId)
            let playersDict = Dictionary(uniqueKeysWithValues: allPlayers.map { ($0.playerId, $0) })

            // Lists to store processed transcripts and key moments.
            var allRecordings: [keyMomentTranscript] = []

            for transcript in transcripts {
                
                // Retrieve the key moment associated with the transcript.
                guard let keyMoment = keyMomentsDict[transcript.keyMomentId] else {
                    print("Key moment not found for transcript \(transcript.transcriptId)")
                    continue
                }
                
                var feedbackPlayers: [PlayerTranscriptInfo]? = []
                if let feedbackFor = keyMoment.feedbackFor {
                    // Players only see their own feedback for privacy reasons
                    if user.userType == .player, let userId = user.userId {
                        if feedbackFor.contains(userId), let p = playersDict[userId] {
                            feedbackPlayers = [p]
                        }
                    } else if user.userType == .coach {
                        // Coaches can see all key moments, so no filtering is needed.
                        feedbackPlayers = feedbackFor.compactMap { playersDict[$0] }
                    } else {
                        // TODO: Unknown user in database. Return error
                    }
                }
                
                let newTranscript = keyMomentTranscript(
                    id: allRecordings.count,
                    keyMomentId: transcript.keyMomentId,
                    transcriptId: transcript.transcriptId,
                    transcript: transcript.transcript,
                    frameStart: keyMoment.frameStart,
                    frameEnd: keyMoment.frameEnd,
                    feedbackFor: feedbackPlayers
                )
                
                allRecordings.append(newTranscript)
            }

            // Sort transcripts by start frame to maintain chronological order.
            return allRecordings.sorted(by: { $0.frameStart < $1.frameStart })
                    
        } catch {
            print("getAllTranscripts: Error when loading the recordings from the database. Error: \(error)")
            return nil
        }
    }
        
    
    /// Retrieves all transcripts and key moments for a specific game.
    ///
    /// - Parameters:
    ///   - gameId: The unique identifier for the game.
    ///   - teamDocId: The unique identifier for the team.
    /// - Returns: A tuple containing two optional arrays:
    ///   - The first array contains key moment transcripts for recorded clips.
    ///   - The second array contains key moments for full-game analysis.
    /// - Throws: An error if the retrieval process fails.
    func getAllTranscriptsAndKeyMoments(gameId: String, teamDocId: String) async throws -> ([keyMomentTranscript]?, [keyMomentTranscript]?) {
        do {
            // Retrieve all transcripts associated with the game.
            guard let transcripts = try await dependencies?.transcriptManager.getAllTranscriptsWithDocId(teamDocId: teamDocId, gameDocId: gameId) else {
                print("No transcripts found") // TO DO - This is not an error because the game doesn't need to have a transcript (e.g. when it is being created -> no transcript)
                return (nil, nil)
            }
            
            // Retrieve the authenticated user.
            guard let user = try await getUser() else {
                print("Could not get user. Aborting..")
                return (nil, nil)
            }
            
            guard let keyMoments = try await dependencies?.keyMomentManager.getAllKeyMomentsWithTeamDocId(teamDocId: teamDocId, gameId: gameId) else {
                print("No key moment found. Aborting..")
                return (nil, nil)
            }
            
            let keyMomentsDict = Dictionary(uniqueKeysWithValues: keyMoments.map { ($0.keyMomentId, $0) })

            // Collect all unique user IDs referenced in feedbackFor
            var allUserIds: Set<String> = []
            for km in keyMoments {
                if let feedbackFor = km.feedbackFor {
                    allUserIds.formUnion(feedbackFor)
                }
            }

            // Fetch all players in a single batch
            let allPlayers = try await getAllPlayersInfo(feedbackFor: Array(allUserIds), teamDocId: teamDocId)
            let playersDict = Dictionary(uniqueKeysWithValues: allPlayers.map { ($0.playerId, $0) })

            // Process transcripts with in-memory lookups only
            var allRecordings: [keyMomentTranscript] = []
            var allKeyMoments: [keyMomentTranscript] = []

            // If full game recording can be found
            let fullGame = try await dependencies?.fullGameRecordingManager.getFullGameVideoWithGameId(teamDocId: teamDocId, gameId: gameId)
            // TODO: Shouldn't be an error here if we can't find a full game recording. However, it should be

            for transcript in transcripts {
                guard let keyMoment = keyMomentsDict[transcript.keyMomentId] else {
                    print("Key moment not found for transcript \(transcript.transcriptId)")
                    continue
                }

                let recordingsLength = allRecordings.count
                let keyMomentsLength = allKeyMoments.count

                var feedbackPlayers: [PlayerTranscriptInfo]? = []
                if let feedbackFor = keyMoment.feedbackFor {
                    if user.userType == .player, let userId = user.userId {
                        // Player only sees their own feedback
                        if feedbackFor.contains(userId), let p = playersDict[userId] {
                            // Add a new transcript
                            let newTranscript = createNewTranscriptKeyMomentObject(
                                id: recordingsLength,
                                transcript: transcript,
                                frameStart: keyMoment.frameStart,
                                frameEnd: keyMoment.frameEnd,
                                feedbackPlayers: [p]
                            )
                            allRecordings.append(newTranscript)
                            
                            if let fullGame = fullGame {
                                // Add to key moments list only if it's tied to a full game
                                if fullGame.fileURL != nil {
                                    let newKeyMom = createNewTranscriptKeyMomentObject(
                                        id: keyMomentsLength,
                                        transcript: transcript,
                                        frameStart: keyMoment.frameStart,
                                        frameEnd: keyMoment.frameEnd,
                                        feedbackPlayers: [p]
                                    )
                                    allKeyMoments.append(newKeyMom)
                                }
                            }
                        }
                    } else if user.userType == .coach {
                        // Coach sees all feedback players
                        feedbackPlayers = feedbackFor.compactMap { playersDict[$0] }
                        
                        // Add a new transcript
                        let newTranscript = createNewTranscriptKeyMomentObject(
                            id: recordingsLength,
                            transcript: transcript,
                            frameStart: keyMoment.frameStart,
                            frameEnd: keyMoment.frameEnd,
                            feedbackPlayers: feedbackPlayers
                        )
                        allRecordings.append(newTranscript)
                        
                        if let fullGame = fullGame {
                            // Add to key moments list only if it's tied to a full game
                            if fullGame.fileURL != nil {
                                let newKeyMom = createNewTranscriptKeyMomentObject(
                                    id: keyMomentsLength,
                                    transcript: transcript,
                                    frameStart: keyMoment.frameStart,
                                    frameEnd: keyMoment.frameEnd,
                                    feedbackPlayers: feedbackPlayers
                                )
                                allKeyMoments.append(newKeyMom)
                            }
                        }
                    } else {
                        // TODO: Unknown user in database. Return error
                    }
                }
            }

            // 7. Sort chronologically
            let sortedTranscripts = allRecordings.sorted { $0.frameStart < $1.frameStart }
            let sortedKeyMoments = allKeyMoments.sorted { $0.frameStart < $1.frameStart }

            return (sortedTranscripts, sortedKeyMoments)
        } catch {
            print("getAllTranscriptsAndKeyMoments: Error when loading the recordings from the database. Error: \(error)")
            return (nil, nil)
        }
    }
    
    
    /// Creates a new `keyMomentTranscript` object from a given transcript and timing information.
    ///
    /// - Parameters:
    ///   - id: A local identifier for the key moment (e.g., list index).
    ///   - transcript: The `DBTranscript` object containing transcript data and IDs.
    ///   - frameStart: The start timestamp of the key moment within the game.
    ///   - frameEnd: The end timestamp of the key moment within the game.
    ///   - feedbackPlayers: An optional array of players linked to this key moment for feedback.
    ///
    /// - Returns: A fully initialized `keyMomentTranscript` object with the provided values.
    func createNewTranscriptKeyMomentObject(id: Int, transcript: DBTranscript, frameStart: Date, frameEnd: Date, feedbackPlayers: [PlayerTranscriptInfo]?) -> keyMomentTranscript  {
        return keyMomentTranscript(
            id: id,
            keyMomentId: transcript.keyMomentId,
            transcriptId: transcript.transcriptId,
            transcript: transcript.transcript,
            frameStart: frameStart,
            frameEnd: frameEnd,
            feedbackFor: feedbackPlayers
        )
    }
    
    
    /// Retrieves 3 transcripts and key moments for a specific game.
    ///
    /// - Parameters:
    ///   - gameId: The unique identifier for the game.
    ///   - teamDocId: The unique identifier for the team.
    /// - Returns: A tuple containing two optional arrays:
    ///   - The first array contains key moment transcripts for recorded clips.
    ///   - The second array contains key moments for full-game analysis.
    /// - Throws: An error if the retrieval process fails.
    func getPreviewTranscriptsAndKeyMoments(gameId: String, teamDocId: String) async throws -> ([keyMomentTranscript]?, [keyMomentTranscript]?) {
        do {
            // Retrieve the first three transcripts associated with the game.
            guard let transcripts = try await dependencies?.transcriptManager.getTranscriptsPreviewWithDocId(teamDocId: teamDocId, gameId: gameId) else {
                print("No transcripts found") // TO DO - This is not an error because the game doesn't need to have a transcript (e.g. when it is being created -> no transcript)
                return (nil, nil)
            }
                        
            // Retrieve the authenticated user.
            guard let user = try await getUser() else {
                print("Could not get user. Aborting..")
                return (nil, nil)
            }
            
            guard let keyMoments = try await dependencies?.keyMomentManager.getAllKeyMomentsWithTeamDocId(teamDocId: teamDocId, gameId: gameId) else {
                print("No key moment found. Aborting..")
                return (nil, nil)
            }
            
            let keyMomentsDict = Dictionary(uniqueKeysWithValues: keyMoments.map { ($0.keyMomentId, $0) })

            // Collect all unique user IDs referenced in feedbackFor
            var allUserIds: Set<String> = []
            for km in keyMoments {
                if let feedbackFor = km.feedbackFor {
                    allUserIds.formUnion(feedbackFor)
                }
            }

            // Fetch all players in a single batch
            let allPlayers = try await getAllPlayersInfo(feedbackFor: Array(allUserIds), teamDocId: teamDocId)
            let playersDict = Dictionary(uniqueKeysWithValues: allPlayers.map { ($0.playerId, $0) })

            // Process transcripts with in-memory lookups only
            var allRecordings: [keyMomentTranscript] = []
            var allKeyMoments: [keyMomentTranscript] = []

            // If full game recording can be found
            let fullGame = try await dependencies?.fullGameRecordingManager.getFullGameVideoWithGameId(teamDocId: teamDocId, gameId: gameId)
            // TODO: Shouldn't be an error here if we can't find a full game recording. However, it should be

            for transcript in transcripts {
                guard let keyMoment = keyMomentsDict[transcript.keyMomentId] else {
                    print("Key moment not found for transcript \(transcript.transcriptId)")
                    continue
                }

                let recordingsLength = allRecordings.count
                let keyMomentsLength = allKeyMoments.count

                var feedbackPlayers: [PlayerTranscriptInfo]? = []
                if let feedbackFor = keyMoment.feedbackFor {
                    if user.userType == .player, let userId = user.userId {
                        // Player only sees their own feedback
                        if feedbackFor.contains(userId), let p = playersDict[userId] {
                            // Add a new transcript
                            let newTranscript = createNewTranscriptKeyMomentObject(
                                id: recordingsLength,
                                transcript: transcript,
                                frameStart: keyMoment.frameStart,
                                frameEnd: keyMoment.frameEnd,
                                feedbackPlayers: [p]
                            )
                            allRecordings.append(newTranscript)
                            
                            if let fullGame = fullGame {
                                // Add to key moments list only if it's tied to a full game
                                if fullGame.fileURL != nil {
                                    let newKeyMom = createNewTranscriptKeyMomentObject(
                                        id: keyMomentsLength,
                                        transcript: transcript,
                                        frameStart: keyMoment.frameStart,
                                        frameEnd: keyMoment.frameEnd,
                                        feedbackPlayers: [p]
                                    )
                                    allKeyMoments.append(newKeyMom)
                                }
                            }
                        }
                    } else if user.userType == .coach {
                        // Coach sees all feedback players
                        feedbackPlayers = feedbackFor.compactMap { playersDict[$0] }
                        
                        // Add a new transcript
                        let newTranscript = createNewTranscriptKeyMomentObject(
                            id: recordingsLength,
                            transcript: transcript,
                            frameStart: keyMoment.frameStart,
                            frameEnd: keyMoment.frameEnd,
                            feedbackPlayers: feedbackPlayers
                        )
                        allRecordings.append(newTranscript)
                        
                        if let fullGame = fullGame {
                            // Add to key moments list only if it's tied to a full game
                            if fullGame.fileURL != nil {
                                let newKeyMom = createNewTranscriptKeyMomentObject(
                                    id: keyMomentsLength,
                                    transcript: transcript,
                                    frameStart: keyMoment.frameStart,
                                    frameEnd: keyMoment.frameEnd,
                                    feedbackPlayers: feedbackPlayers
                                )
                                allKeyMoments.append(newKeyMom)
                            }
                        }
                    } else {
                        // TODO: Unknown user in database. Return error
                    }
                }
            }

            // 7. Sort chronologically
            let sortedTranscripts = allRecordings.sorted { $0.frameStart < $1.frameStart }
            let sortedKeyMoments = allKeyMoments.sorted { $0.frameStart < $1.frameStart }

            return (sortedTranscripts, sortedKeyMoments)
        } catch {
            print("getPreviewTranscriptsAndKeyMoments: Error when loading the recordings from the database. Error: \(error)")
            return (nil, nil)
        }
    }
    
    
    /// Retrieves information for a list of players based on their IDs.
    ///
    /// - Parameter feedbackFor: An array of player IDs.
    /// - Returns: An array of `PlayerTranscriptInfo` objects containing player details.
    /// - Throws: An error if any player information retrieval fails.
    func getAllPlayersInfo (feedbackFor: [String]?, teamDocId: String) async throws -> [PlayerTranscriptInfo] {
        guard let team = try await dependencies?.teamManager.getTeamWithDocId(docId: teamDocId) else {
            // TODO: Throw error
            throw TeamError.teamNotFound
        }
        var tmpPlayer: [PlayerTranscriptInfo] = []
        if let feedbackFor = feedbackFor {
            for playerId in feedbackFor {
                let player = try await loadPlayerInfo(playerId: playerId, teamId: team.teamId)!;
                
                tmpPlayer.append(player)
            }
        }
        return tmpPlayer
    }
    
    
    /// Retrieves detailed player information based on a given player ID.
    ///
    /// - Parameter playerId: The ID of the player.
    /// - Returns: A `PlayerTranscriptInfo` object containing the player's details, or `nil` if not found.
    /// - Throws: An error if retrieval fails.
    func loadPlayerInfo(playerId: String, teamId: String) async throws -> PlayerTranscriptInfo? {
        // Retrieve user information.
        guard let user = try await dependencies?.userManager.getUser(userId: playerId) else {
            print("no user found. abort")
            return nil
        }
        
        guard let player = try await dependencies?.playerManager.getPlayer(playerId: playerId) else {
            print("no player found. abort")
            return nil
        }

        // Retrieve player-specific information.
        guard let playerTeamInfo = try await dependencies?.playerTeamInfoManager.getPlayerTeamInfo(playerDocId: player.id, teamId: teamId) else {
            // TODO: Throw error
            throw PlayerTeamInfoError.playerTeamInfoNotFound
        }
        
        // Create a structured player object.
        let playerObject = PlayerTranscriptInfo(
            playerId: playerId,
            firstName: user.firstName,
            lastName: user.lastName,
            nickname: playerTeamInfo.nickName,
            jersey: playerTeamInfo.jerseyNum ?? 0
        )
        
        return playerObject
    }
    
    
    func getAudioFileUrl(keyMomentId: String, gameId: String, teamId: String) async throws -> String? {
        guard let keyMomentAudioURL = try await dependencies?.keyMomentManager.getKeyMoment(teamId: teamId, gameId: gameId, keyMomentDocId: keyMomentId)?.audioUrl else {
            return nil
        }
        
        return keyMomentAudioURL
    }

    
    /// Retrieves the names and profile pictures of players mentioned in feedback.
    ///
    /// - Parameter feedbackFor: An array of player IDs.
    /// - Returns: An array of `PlayerNameAndPhoto` objects containing player names and profile pictures.
    /// - Throws: An error if retrieval fails.
    func getFeebackFor(feedbackFor: [String]) async throws -> [PlayerNameAndPhoto] {
        var results: [PlayerNameAndPhoto] = []
        for id in feedbackFor {
            if let user = try await dependencies?.userManager.getUser(userId: id) {
                print("player: \(user.firstName) \(user.lastName)")
                results.append(
                    PlayerNameAndPhoto(playerId: id, name: user.firstName + " " + user.lastName, photoURL: nil)
                )
            }
        }
        return results
    }
    
    
    /// Updates transcript information in the database.
    ///
    /// - Parameters:
    ///   - teamDocId: Firestore document ID for the team.
    ///   - teamId: Team identifier.
    ///   - gameId: Game identifier.
    ///   - transcriptId: Transcript identifier.
    ///   - feedbackFor: Optional list of players receiving feedback.
    ///   - transcript: Optional updated transcript text.
    ///
    /// - Throws: If updating feedback or transcript fails.
    func updateTranscriptInfo(
        teamDocId: String,
        teamId: String,
        gameId: String,
        transcriptId: String,
        feedbackFor: [PlayerNameAndPhoto]?,
        transcript: String?
    ) async throws {
        if let feedbackFor = feedbackFor {
            try await dependencies?.keyMomentManager.updateFeedbackFor(
                transcriptId: transcriptId,
                gameId: gameId,
                teamId: teamId,
                teamDocId: teamDocId,
                feedbackFor: feedbackFor // save selected players
            )
        }
        
        if let transcript = transcript {
            try await dependencies?.transcriptManager.updateTranscript(teamDocId: teamDocId, gameId: gameId, transcriptId: transcriptId, transcript: transcript)
        }
    }
    
    
    /// Removes a transcript and its associated key moment from the database.
    ///
    /// - Parameters:
    ///   - gameId: The unique identifier of the game the transcript belongs to.
    ///   - teamId: The unique identifier of the team associated with the game.
    ///   - transcriptId: The unique identifier of the transcript to remove.
    ///   - keyMomentId: The unique identifier of the key moment associated with the transcript.
    /// - Throws: Propagates any errors thrown by `TranscriptManager` or `KeyMomentManager` during deletion.
    func removeTranscript(gameId: String, teamId: String, transcriptId: String, keyMomentId: String) async throws {
        // Remove transcript first
        try await dependencies?.transcriptManager.removeTranscript(teamId: teamId, gameId: gameId, transcriptId: transcriptId)
        
        // Get the audio url before deleting the key moment document
        let audioUrl = try await dependencies?.keyMomentManager.getAudioUrl(teamDocId: teamId, gameDocId: gameId, keyMomentId: keyMomentId)
        
        // Remove key moment
        try await dependencies?.keyMomentManager.removeKeyMoment(teamId: teamId, gameId: gameId, keyMomentId: keyMomentId)

        guard audioUrl != nil else { return }
        print("audioUrl: \(audioUrl! ?? "nil")")
        
        // Remove the audio from the storage database
        StorageManager.shared.deleteAudio(path: audioUrl!)  { error in
            if let error = error {
                print("Failed to delete: \(error.localizedDescription)")
            } else {
                print("Deleted successfully!")
            }
        }
    }
    
    /** FOLLOWING FUNCTIONS ARE NOT BEING USED AT THE MOMENT */
    // Load a batch of transcripts
    func loadTranscriptsBatch(teamDocId: String, gameId: String, search: String? = nil, startAfterId: String? = nil) async throws -> [DBTranscript] {
        let transcriptRepo = FirestoreTranscriptRepository()
        let collection = transcriptRepo.transcriptCollection(teamDocId: teamDocId, gameDocId: gameId)
        var query = collection.order(by: "key_moment_id").limit(to: 20)

        if let search = search, !search.isEmpty {
            query = query.whereField("transcript", isGreaterThanOrEqualTo: search)
                         .whereField("transcript", isLessThanOrEqualTo: search + "\u{f8ff}")
        }

        if let startAfterId = startAfterId {
            // paginate
            let lastDoc = try await collection.document(startAfterId).getDocument()
            query = query.start(afterDocument: lastDoc)
        }

        let snapshot = try await query.getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: DBTranscript.self) }
    }

    // Only fetch keyMoments when user taps a transcript
    func loadKeyMoments(teamDocId: String, gameId: String, keyMomentIds: [String]) async throws -> [DBKeyMoment] {
        let keyMomentRepo = FirestoreKeyMomentRepository()
        let collection = keyMomentRepo.keyMomentCollection(teamDocId: teamDocId, gameDocId: gameId)
        
        guard !keyMomentIds.isEmpty else { return [] }
        let snapshot = try await collection.whereField("key_moment_id", in: keyMomentIds).getDocuments()

        return snapshot.documents.compactMap { try? $0.data(as: DBKeyMoment.self) }
    }
    
    func loadKeyMomentsBatch(teamDocId: String, gameId: String, playerId: String?, filterByTime: Bool, startAfterId: String? = nil) async throws -> [DBKeyMoment] {
        let keyMomentRepo = FirestoreKeyMomentRepository()
        let collection = keyMomentRepo.keyMomentCollection(teamDocId: teamDocId, gameDocId: gameId)
        
        var query = collection.order(by: filterByTime ? "key_moment_id" : "frame_start").limit(to: 20)
        
        if let playerId = playerId, !playerId.isEmpty {
            query = query.whereField("feedback_for", arrayContains: playerId)
        }
        if let startAfterId = startAfterId {
            // paginate
            let lastDoc = try await collection.document(startAfterId).getDocument()
            query = query.start(afterDocument: lastDoc)
        }

        let snapshot = try await query.getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: DBKeyMoment.self) }
    }
    

    // Only fetch transcripts when user taps a transcript
    func loadTranscripts(teamDocId: String, gameId: String, search: String?) async throws -> [DBTranscript] {
        let transcriptRepo = FirestoreTranscriptRepository()
        let collection = transcriptRepo.transcriptCollection(teamDocId: teamDocId, gameDocId: gameId)
        var query = collection.order(by: "transcript_id").limit(to: 20)

        if let search = search, !search.isEmpty {
            query = query.whereField("transcript", isGreaterThanOrEqualTo: search)
                         .whereField("transcript", isLessThanOrEqualTo: search + "\u{f8ff}")
        }

        let snapshot = try await query.getDocuments()

        return snapshot.documents.compactMap { try? $0.data(as: DBTranscript.self) }
    }

}
