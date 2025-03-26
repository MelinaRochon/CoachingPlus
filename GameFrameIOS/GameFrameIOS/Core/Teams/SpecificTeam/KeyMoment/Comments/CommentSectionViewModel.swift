//
//  CommentSectionViewModel.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-03-26.
//

import Foundation

@MainActor
final class CommentSectionViewModel: ObservableObject {
        @Published var comments: [DBComment] = []
    
        /** Fetch all comments for the given key moment */
        func loadComments(teamId: String, keyMomentId: String) async {
            guard !teamId.isEmpty, !keyMomentId.isEmpty else {
                        print("Invalid teamId or keyMomentId")
                        return
                    }
            do {
                if let fetchedComments = try await CommentManager.shared.getAllCommentsForSpecificKeyMomentId(teamId: teamId, keyMomentId: keyMomentId) {
                    self.comments = fetchedComments.sorted { $0.createdAt > $1.createdAt } // Order by newest first
                } else {
                    self.comments = [] // Ensures empty list instead of nil
                }
            } catch {
                print("Error fetching comments: \(error)")
            }
        }

        /** Add a new comment to the Firestore database */
        func addComment(teamId: String, keyMomentId: String, gameId: String, transcriptId: String, text: String) async {
            do {
                guard !teamId.isEmpty, !keyMomentId.isEmpty, !text.isEmpty else {
                            print("Invalid input values, cannot add comment")
                            return
                        }
                
                let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
                let newComment = CommentDTO(
                    keyMomentId: keyMomentId,
                    gameId: gameId,
                    transcriptId: transcriptId,
                    uploadedBy: authUser.email ?? "Unknown User",
                    comment: text,
                    createdAt: Date()
                )

                try await CommentManager.shared.addNewComment(teamId: teamId, commentDTO: newComment)
                
                // Refresh comments after adding
                await loadComments(teamId: teamId, keyMomentId: keyMomentId)
            } catch {
                print("Error adding comment: \(error)")
            }
        }
    
}
