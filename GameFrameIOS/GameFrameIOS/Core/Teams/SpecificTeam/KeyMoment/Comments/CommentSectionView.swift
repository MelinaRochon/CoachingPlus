//
//  CommentSectionView.swift
//  GameFrameIOS
//
//  Created by Caterina Bosi on 2025-03-26.
//

import SwiftUI

struct CommentSectionView: View {
    @ObservedObject var viewModel: CommentSectionViewModel
    @State private var newComment: String = ""
    
    var teamId: String
    var keyMomentId: String
    var gameId: String
    var transcriptId: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Comments")
                .font(.headline)
                .padding(.horizontal)

            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(viewModel.comments, id: \.commentId) { comment in
                        VStack(alignment: .leading) {
                            Text(comment.uploadedBy)
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(comment.comment)
                                .font(.body)
                                .padding(.vertical, 4)
                            Text(comment.createdAt.formatted(.dateTime.year().month().day().hour().minute()))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Divider()
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .frame(height: 200)

            HStack {
                TextField("Write a comment...", text: $newComment)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(height: 40)

                Button(action: {
                    Task {
                        if !newComment.trimmingCharacters(in: .whitespaces).isEmpty {
                            await viewModel.addComment(teamId: teamId, keyMomentId: keyMomentId, gameId: gameId, transcriptId: transcriptId, text: newComment)
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
            await viewModel.loadComments(teamId: teamId, keyMomentId: keyMomentId)
        }
    }
}

#Preview {
    CommentSectionView(
        viewModel: CommentSectionViewModel(),
        teamId: "mockTeamId",
        keyMomentId: "mockKeyMomentId",
        gameId: "mockGameId",
        transcriptId: "mockTranscriptId"
    )
}
