//
//  CommentSectionViewModel.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-03-26.
//

import Foundation
import GameFrameIOSShared

/**
 `CommentSectionViewModel` is a view model that handles the logic for managing comments in the `CommentSectionView`.
 It is responsible for loading comments for specific game transcripts and key moments, adding new comments, and maintaining the list of comments.
 */
@MainActor
final class CommentSectionViewModel: ObservableObject {
    
    /// Holds the app’s shared dependency container, used to access services and repositories.
    private var dependencies: DependencyContainer?

    /**
     A published property that holds the list of comments for a specific key moment or transcript.
     This will automatically update the view when the comments are loaded or modified.
     */
    @Published var comments: [DBComment] = []
    
    private var commentRepo: CommentRepository!
    private var notificationManager: NotificationManager?
    private var teamManager: TeamManager?
    private var transcriptModel: TranscriptModel?
    private var playerModel: PlayerModel?
    private var coachModel: CoachManager?
    private var authManager: AuthenticationManager?
    private var userManager: UserManager?

    // MARK: - Dependency Injection
    
    /// Injects the provided `DependencyContainer` into the current context.
    ///
    /// This allows the view, view model, or controller to access shared
    /// dependencies such as managers or repositories from a central container.
    /// Useful for testing, environment configuration (e.g., local vs. Firestore),
    /// or replacing dependencies at runtime.
    func setDependencies(_ dependencies: DependencyContainer) {
        self.dependencies = dependencies
        // wire managers from the container
        self.notificationManager = dependencies.notificationManager
        self.teamManager = dependencies.teamManager
        self.authManager = dependencies.authenticationManager

        // create/use models that themselves need dependencies
        let tModel = TranscriptModel()
        tModel.setDependencies(dependencies)
        self.transcriptModel = tModel

        let pModel = PlayerModel()
        pModel.setDependencies(dependencies)
        self.playerModel = pModel
    }

    /**
     Fetches all comments for a given key moment.
     - Parameters:
        - teamId: The identifier of the team for which comments are being fetched.
        - keyMomentId: The identifier of the key moment related to the comments.
     This function interacts with the `CommentManager` to retrieve the comments from Firestore and updates the `comments` property.
     */
    func loadCommentsForKeyMoment(teamId: String, keyMomentId: String) async {
        guard !teamId.isEmpty, !keyMomentId.isEmpty else {
            print("Invalid teamId or keyMomentId")
            return
        }
        do {
            if let fetchedComments = try await dependencies?.commentManager.getAllCommentsForSpecificKeyMomentId(teamId: teamId, keyMomentId: keyMomentId) {
                self.comments = fetchedComments.sorted { $0.createdAt > $1.createdAt } // Order by newest first
                print("Loaded \(self.comments.count) comments")
            } else {
                self.comments = [] // Ensures empty list instead of nil
            }
        } catch {
            print("Error fetching comments: \(error)")
        }
    }
    
    /**
     Fetches all comments for a given transcript.
     - Parameters:
        - teamDocId: The identifier for the team document.
        - transcriptId: The identifier of the transcript related to the comments.
     
     This function retrieves all comments related to a transcript and updates the `comments` property with the result.
     It also replaces the `uploadedBy` field with the user's full name.
     */
    func loadCommentsForTranscript(teamDocId: String, transcriptId: String) async {
        print("LOADCOMMENTS$TRANSCRIPTS")
        print(teamDocId)
        print(transcriptId)
        guard !teamDocId.isEmpty, !transcriptId.isEmpty else {
            print("Invalid teamId or transcriptId")
            return
        }
            
        do {
            if let fetchedComments = try await dependencies?.commentManager.getAllCommentsForSpecificTranscriptId(teamDocId: teamDocId, transcriptId: transcriptId) {
                var updatedComments: [DBComment] = []
                for comment in fetchedComments {
                    if let user = try? await dependencies?.userManager.getUser(userId: comment.uploadedBy) {
                        let updatedComment = DBComment(
                            commentId: comment.commentId,
                            keyMomentId: comment.keyMomentId,
                            gameId: comment.gameId,
                            transcriptId: comment.transcriptId,
                            uploadedBy: "\(user.firstName) \(user.lastName)", // Replace userId with full name
                            comment: comment.comment,
                            createdAt: comment.createdAt,
                            parentCommentId: comment.parentCommentId
                        )
                        updatedComments.append(updatedComment)
                    } else {
                        updatedComments.append(comment)
                    }
                }
                
                self.comments = updatedComments.sorted { $0.createdAt > $1.createdAt }
                print("Loaded \(self.comments.count) comments for transcriptId: \(transcriptId)")
            } else {
                self.comments = []
            }
        } catch {
            print("Error fetching comments: \(error)")
        }

        }

    /**
     Adds a new comment to the Firestore database.
     
     - Parameters:
        - teamDocId: The identifier for the team document.
        - keyMomentId: The identifier of the key moment related to the comment.
        - gameId: The identifier of the game the comment pertains to.
        - transcriptId: The identifier of the transcript the comment belongs to.
        - text: The text content of the comment.
     
     This function creates a new `CommentDTO` object and adds it to Firestore. After adding, it reloads the comments for the given transcript.
     */
    func addComment(teamDocId: String, keyMomentId: String, gameId: String, transcriptId: String, text: String, parentCommentId: String? = nil) async {
        do {
            print("In CommentSectionViewModel, teamId: \(teamDocId)")
            guard !teamDocId.isEmpty, !keyMomentId.isEmpty, !text.isEmpty else {
                print("Invalid input values, cannot add comment")
                return
            }
            
            guard let repo = dependencies?.authenticationManager else {
                print("⚠️ Dependencies not set")
                return
            }

            let authUser = try repo.getAuthenticatedUser()
            let currentUserId = authUser.uid
            print("THE CURRENT LOGGED IN USER: \(currentUserId)")
            
//            let user = try? await dependencies?.userManager.getUser(userId: currentUserId)
            guard let user = try await dependencies?.userManager.getUser(userId: currentUserId) else {
                print("⚠️ Could not load domain user for uid \(currentUserId)")
                return
            }
            let currentUserDocId = user.id
            let displayName = "\(user.firstName ?? "Someone") \(user.lastName ?? "")"

            let newComment = CommentDTO(
                keyMomentId: keyMomentId,
                gameId: gameId,
                transcriptId: transcriptId,
                uploadedBy: currentUserId ?? "Unknown User",
                comment: text,
                createdAt: Date(),
                parentCommentId: parentCommentId
            )
            print("trying to add comment: \(text)")
            let commentId = try await dependencies?.commentManager.addNewComment(teamDocId: teamDocId, commentDTO: newComment)
            print("success!")
            
            var recipients = Set<String>()
            
            let kmRecipients = try await recipientsForKeyMomentComment(
                teamDocId: teamDocId,
                gameId: gameId,
                keyMomentId: keyMomentId,
                currentUserDocId: currentUserId
            )
            recipients.formUnion(kmRecipients)


            let isKeyMoment = !keyMomentId.isEmpty
            let type: NotificationType = isKeyMoment ? .commentOnKeyMoment : .commentOnTranscript
            let title: String = isKeyMoment
                ? "New comment on a key moment"
                : "New comment on a transcript"
            let body: String = "\(displayName) commented: \"\(text)\""
            print("notification body: \(body)")

            for recipientUserDocId in recipients {
                if recipientUserDocId == currentUserDocId { continue }
                
                guard let toUserDocId = try await dependencies?
                    .userManager
                    .getUser(userId: recipientUserDocId)?
                    .id else {
                    // if we can't resolve the user, skip this recipient
                    continue
                }
                
                _ = try await notificationManager?.createCommentNotification(
                    toUserDocId: toUserDocId,
                    playerDocId: nil,              // or a specific playerDocId if needed
                    teamDocId: teamDocId,
                    teamId: nil,                   // or team.teamId if you want
                    gameId: gameId,
                    keyMomentId: keyMomentId,
                    transcriptId: transcriptId,
                    commentId: commentId ?? "",
                    type: type,
                    title: title,
                    body: body
                )
            }
            print("success adding notif!")

            // 5) Refresh UI
            await loadCommentsForTranscript(teamDocId: teamDocId, transcriptId: transcriptId)

        } catch {
            print("Error adding comment: \(error)")
        }
    }

    /**
     Adds a reply to an existing comment in the Firestore database.

     - Parameters:
        - teamDocId: The identifier for the team document.
        - keyMomentId: The identifier of the key moment related to the reply.
        - gameId: The identifier of the game the reply pertains to.
        - transcriptId: The identifier of the transcript the reply belongs to.
        - parentCommentId: The identifier of the comment being replied to.
        - text: The text content of the reply.

     This function builds a `CommentDTO` with `parentCommentId` set to the target
     comment, writes it to Firestore, and then reloads the comments for the given
     transcript so the UI reflects the new reply. Input values are validated and the
     operation is performed on the main actor to keep UI state in sync.
    */
    func addReply(
        teamDocId: String,
        keyMomentId: String,
        gameId: String,
        transcriptId: String,
        parentCommentId: String,
        text: String
    ) async {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !teamDocId.isEmpty, !keyMomentId.isEmpty, !transcriptId.isEmpty,
              !parentCommentId.isEmpty, !trimmed.isEmpty else {
            print("Invalid input values, cannot add reply")
            return
        }
        guard let auth = dependencies?.authenticationManager else {
            print("Dependencies not set")
            return
        }
        do {
            let user = try auth.getAuthenticatedUser()
            let dto = CommentDTO(
                keyMomentId: keyMomentId,
                gameId: gameId,
                transcriptId: transcriptId,
                uploadedBy: user.uid ?? "Unknown User",
                comment: trimmed,
                createdAt: Date(),
                parentCommentId: parentCommentId
            )
            try await dependencies?.commentManager.addNewComment(teamDocId: teamDocId, commentDTO: dto)
            await loadCommentsForTranscript(teamDocId: teamDocId, transcriptId: transcriptId)
            print("Added reply to \(parentCommentId)")
        } catch {
            print("Error adding reply: \(error)")
        }
    }
    
    private func recipientsForKeyMomentComment(
            teamDocId: String,
            gameId: String,
            keyMomentId: String,
            currentUserDocId: String
        ) async throws -> Set<String> {
            var recipients = Set<String>()
            print("recipientsForKeyMomentComment")
            
            // 1) Team -> coaches
            if let team = try await dependencies?.teamManager.getTeamWithDocId(docId: teamDocId) {
                for coachId in team.coaches where coachId != currentUserDocId {
                    if coachId == currentUserDocId { continue }
                    
                    recipients.insert(coachId)
                }
            }

            // 2) Key moment -> feedbackFor players
            if let transcriptModel {
                let allKeyMoments = try await transcriptModel.getAllTranscripts(
                    gameId: gameId,
                    teamDocId: teamDocId
                ) ?? []
                guard let km = allKeyMoments.first(where: { $0.keyMomentId == keyMomentId }) else {
                    return recipients
                }

                let feedbackPlayers = km.feedbackFor ?? []
                for player in feedbackPlayers {
                    
                let playerDocId = player.playerId

                // playerModel might be optional, dbPlayer is NOT optional
                if let playerModel {
                    if playerDocId != currentUserDocId {
                    recipients.insert(playerDocId)
                }
            }
        }
    }
    print("final list:")
    print(recipients)
    return recipients
    }
}
