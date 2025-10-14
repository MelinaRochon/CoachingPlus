//
//  CommentSectionViewModel.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-03-26.
//

import Foundation

/**
 `CommentSectionViewModel` is a view model that handles the logic for managing comments in the `CommentSectionView`.
 It is responsible for loading comments for specific game transcripts and key moments, adding new comments, and maintaining the list of comments.
 */
@MainActor
final class CommentSectionViewModel: ObservableObject {
    /**
     A published property that holds the list of comments for a specific key moment or transcript.
     This will automatically update the view when the comments are loaded or modified.
     */
    @Published var comments: [DBComment] = []
        
    /**
     Fetches all comments for a given key moment.
     - Parameters:
        - teamId: The identifier of the team for which comments are being fetched.
        - keyMomentId: The identifier of the key moment related to the comments.
     This function interacts with the `CommentManager` to retrieve the comments from Firestore and updates the `comments` property.
     */
    func loadCommentsForKeyMoment(teamId: String, keyMomentId: String) async {
        let commentManager = CommentManager()
        guard !teamId.isEmpty, !keyMomentId.isEmpty else {
            print("Invalid teamId or keyMomentId")
            return
        }
        do {
            if let fetchedComments = try await commentManager.getAllCommentsForSpecificKeyMomentId(teamId: teamId, keyMomentId: keyMomentId) {
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
        let commentManager = CommentManager()
        guard !teamDocId.isEmpty, !transcriptId.isEmpty else {
            print("Invalid teamId or transcriptId")
            return
        }
            
        do {
            if let fetchedComments = try await commentManager.getAllCommentsForSpecificTranscriptId(teamDocId: teamDocId, transcriptId: transcriptId) {
                let userManager = UserManager()
                
                var updatedComments: [DBComment] = []
                for comment in fetchedComments {
                    if let user = try? await userManager.getUser(userId: comment.uploadedBy) {
                        let updatedComment = DBComment(
                            commentId: comment.commentId,
                            keyMomentId: comment.keyMomentId,
                            gameId: comment.gameId,
                            transcriptId: comment.transcriptId,
                            uploadedBy: "\(user.firstName) \(user.lastName)", // Replace userId with full name
                            comment: comment.comment,
                            createdAt: comment.createdAt
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
    func addComment(teamDocId: String, keyMomentId: String, gameId: String, transcriptId: String, text: String) async {
        let commentManager = CommentManager()
        do {
            print("In CommentSectionViewModel, teamId: \(teamDocId)")
            guard !teamDocId.isEmpty, !keyMomentId.isEmpty, !text.isEmpty else {
                print("Invalid input values, cannot add comment")
                return
            }
            
            let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
            let newComment = CommentDTO(
                keyMomentId: keyMomentId,
                gameId: gameId,
                transcriptId: transcriptId,
                uploadedBy: authUser.uid ?? "Unknown User",
                comment: text,
                createdAt: Date()
            )
            print("trying to add comment: \(text)")
            try await commentManager.addNewComment(teamDocId: teamDocId, commentDTO: newComment)
            print("success!")
            
            // Refresh comments after adding
            print("loading comments")
            await loadCommentsForTranscript(teamDocId: teamDocId, transcriptId: transcriptId)
        } catch {
            print("Error adding comment: \(error)")
        }
    }
    
}
