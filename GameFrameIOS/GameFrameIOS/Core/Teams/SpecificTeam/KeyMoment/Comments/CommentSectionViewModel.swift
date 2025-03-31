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
    
//        func loadComments(teamId: String, keyMomentId: String) async {
//            guard !teamId.isEmpty, !keyMomentId.isEmpty else {
//                        print("Invalid teamId or keyMomentId")
//                        return
//                    }
//            do {
//                if let fetchedComments = try await CommentManager.shared.getAllCommentsForSpecificKeyMomentId(teamId: teamId, keyMomentId: keyMomentId) {
//                    self.comments = fetchedComments.sorted { $0.createdAt > $1.createdAt } // Order by newest first
//                    print("Loaded \(self.comments.count) comments")
//                } else {
//                    self.comments = [] // Ensures empty list instead of nil
//                }
//            } catch {
//                print("Error fetching comments: \(error)")
//            }
//        }
    
    /** Fetch all comments for the given key moment */
    func loadCommentsForKeyMoment(teamId: String, keyMomentId: String) async {
                guard !teamId.isEmpty, !keyMomentId.isEmpty else {
                            print("Invalid teamId or keyMomentId")
                            return
                        }
                do {
                    if let fetchedComments = try await CommentManager.shared.getAllCommentsForSpecificKeyMomentId(teamId: teamId, keyMomentId: keyMomentId) {
                        self.comments = fetchedComments.sorted { $0.createdAt > $1.createdAt } // Order by newest first
                        print("Loaded \(self.comments.count) comments")
                    } else {
                        self.comments = [] // Ensures empty list instead of nil
                    }
                } catch {
                    print("Error fetching comments: \(error)")
                }
            }
    
    /** Fetch all comments for the given transcript */
    func loadCommentsForTranscript(teamId: String, transcriptId: String) async {
        guard !teamId.isEmpty, !transcriptId.isEmpty else {
                            print("Invalid teamId or transcriptId")
                            return
                        }
                do {
                    if let fetchedComments = try await CommentManager.shared.getAllCommentsForSpecificTranscriptId(teamId: teamId, transcriptId: transcriptId) {
                        self.comments = fetchedComments.sorted { $0.createdAt > $1.createdAt } // Order by newest first
                        print("Loaded \(self.comments.count) comments")
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
                print("In CommentSectionViewModel, teamId: \(teamId)")
                guard !teamId.isEmpty, !keyMomentId.isEmpty, !text.isEmpty else {
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
                try await CommentManager.shared.addNewComment(teamId: teamId, commentDTO: newComment)
                print("success!")
                
                // Refresh comments after adding
                print("loading comments")
                await loadCommentsForKeyMoment(teamId: teamId, keyMomentId: keyMomentId)
            } catch {
                print("Error adding comment: \(error)")
            }
        }
    
}
