import SwiftUI
import GameFrameIOSShared

struct CommentSectionView: View {
    @ObservedObject var viewModel: CommentSectionViewModel

    @State private var newComment: String = ""
    @State private var replyText: String = ""
    @State private var replyingToId: String? = nil   // which parent is being replied to

    var teamDocId: String
    var keyMomentId: String
    var gameId: String
    var transcriptId: String

    @EnvironmentObject private var dependencies: DependencyContainer

    // MARK: - Thread helpers (keeps body simple)
    private var roots: [DBComment] {
        viewModel.comments.filter { ($0.parentCommentId?.isEmpty ?? true) }
            .sorted { $0.createdAt < $1.createdAt }
    }
    private var repliesByParent: [String: [DBComment]] {
        Dictionary(
            grouping: viewModel.comments.compactMap { c in
                guard let p = c.parentCommentId, !p.isEmpty else { return nil }
                return c
            },
            by: { $0.parentCommentId! }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Comments")
                .font(.headline)
                .padding(.horizontal)
                .padding(.top)

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if viewModel.comments.isEmpty {
                        Text("No comments yet. Be the first to comment!")
                            .font(.caption)
                                            .foregroundColor(.gray)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.top, 8)
                    } else {
                        ForEach(roots, id: \.commentId) { parent in
                            CommentRow(comment: parent)

                            Button("Reply") { replyingToId = parent.commentId }
                                .font(.caption)
                                .foregroundColor(.blue)
                                .buttonStyle(.plain)
                                .padding(.leading, 44)

                            // Inline reply composer for this parent
                            if replyingToId == parent.commentId {
                                replyComposer(parentId: parent.commentId)
                                    .padding(.horizontal)
                            }

                            // Replies (indented)
                            if let replies = repliesByParent[parent.commentId] {
                                ForEach(replies.sorted { $0.createdAt < $1.createdAt }, id: \.commentId) { reply in
                                    CommentRow(comment: reply)
                                        .padding(.leading, 40)
                                }
                            }

                            Divider().padding(.leading, 16)
                        }
                    }
                }.padding(.horizontal)
//                .padding(.bottom, 96) // space so last row isn't covered by input bar
            }
        }
        .safeAreaInset(edge: .bottom) {
            inputBar
                .ignoresSafeArea(.keyboard, edges: .bottom)
                .zIndex(1000)
        } // main comment composer
        .task {
            await viewModel.loadCommentsForTranscript(teamDocId: teamDocId, transcriptId: transcriptId)
        }
        .onAppear {
            viewModel.setDependencies(dependencies)
        }
    }

    // MARK: - Inline reply composer
    @ViewBuilder
    private func replyComposer(parentId: String) -> some View {
        HStack(spacing: 8) {
            TextField("Write a reply…", text: $replyText)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemBackground))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(.separator), lineWidth: 1))
                )
            Button {
                Task {
                    let text = replyText.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !text.isEmpty else { return }
                    await viewModel.addReply(
                        teamDocId: teamDocId,
                        keyMomentId: keyMomentId,
                        gameId: gameId,
                        transcriptId: transcriptId,
                        parentCommentId: parentId,
                        text: text
                    )
                    replyText = ""
                    replyingToId = nil
                }
            } label: {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(replyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .red)
            }
            .disabled(replyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }

    // MARK: - Bottom input bar (new top-level comment)
    private var inputBar: some View {
        VStack(spacing: 0) {
            Color.white.frame(height: 12)
            HStack(spacing: 8) {
                TextField("Write a comment…", text: $newComment)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemBackground))
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(.separator), lineWidth: 1))
                    )
                Button {
                    Task {
                        let text = newComment.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !text.isEmpty else { return }
                        await viewModel.addComment(
                            teamDocId: teamDocId,
                            keyMomentId: keyMomentId,
                            gameId: gameId,
                            transcriptId: transcriptId,
                            text: text
                        )
                        newComment = ""
                    }
                } label: {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .red)
                }
                .disabled(newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .overlay(Divider(), alignment: .top)
        }
        .zIndex(1)
    }
}

// Small reusable row
private struct CommentRow: View {
    let comment: DBComment
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(.gray)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(comment.uploadedBy).font(.subheadline).bold()
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
