//
//  CommentSectionView.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-03-26.
//

import SwiftUI

/**
 `CommentSectionView` is a SwiftUI view that displays the comments for a specific game transcript.
 It allows users to view existing comments, add new comments, and provides a user-friendly interface for interacting with the comments section.
 */
struct CommentSectionView: View {
    /**
     The view model that handles the business logic for fetching and adding comments.
     It is an `ObservedObject` because it needs to be updated whenever its state changes (e.g., when new comments are loaded or added).
    */
    @ObservedObject var viewModel: CommentSectionViewModel

    /**
     A state variable to hold the text of the new comment as the user types it.
     This is a two-way binding between the text field and the view model, allowing dynamic updates.
    */
    @State private var newComment: String = ""

    /**
     The identifiers for the specific team, key moment, game, and transcript related to the comments.
     These IDs are passed to the view to identify the context for which comments are being displayed and added.
    */
    var teamDocId: String
    var keyMomentId: String
    var gameId: String
    var transcriptId: String
    @EnvironmentObject private var dependencies: DependencyContainer

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Comments")
                .font(.headline)
                .padding(.horizontal)
                .padding(.top)

            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    if viewModel.comments.isEmpty {
                        Text("No comments yet. Be the first to comment!").font(.caption)
                            .foregroundColor(.gray)
                            .padding()
                    }
                    ForEach(viewModel.comments, id: \.commentId) { comment in
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.gray)

                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(comment.uploadedBy)
                                        .font(.subheadline)
                                        .bold()
                                    
                                    Spacer()
                                    
                                    Text(comment.createdAt.formatted(.dateTime.hour().minute()))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Text(comment.comment)
                                    .font(.body)
                                    .padding(10)
                                    .background(Color(UIColor.systemGray6))
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .frame(height: 200)
            
            Spacer()
            // Comment Input Section
            HStack {
                TextField("Write a comment...", text: $newComment)
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))

                Button(action: {
                    Task {
                        if !newComment.trimmingCharacters(in: .whitespaces).isEmpty {
                            print("in CommentSectionView, teamId: \(teamDocId)")
                            await viewModel.addComment(teamDocId: teamDocId, keyMomentId: keyMomentId, gameId: gameId, transcriptId: transcriptId, text: newComment)
                            DispatchQueue.main.async {
                                newComment = "" // Clear input field safely
                            }
                        }
                    }
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(newComment.isEmpty ? .gray : .blue)
                }
                .disabled(newComment.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.horizontal)
        }
        .task {
            await viewModel.loadCommentsForTranscript(teamDocId: teamDocId, transcriptId: transcriptId)
        }
        .onAppear {
            viewModel.setDependencies(dependencies)
        }
    }
}

#Preview {
    CommentSectionView(
        viewModel: CommentSectionViewModel(),
        teamDocId: "mockTeamId",
        keyMomentId: "mockKeyMomentId",
        gameId: "mockGameId",
        transcriptId: "mockTranscriptId"
    )
}
