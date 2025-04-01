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

    var teamDocId: String
    var keyMomentId: String
    var gameId: String
    var transcriptId: String

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
