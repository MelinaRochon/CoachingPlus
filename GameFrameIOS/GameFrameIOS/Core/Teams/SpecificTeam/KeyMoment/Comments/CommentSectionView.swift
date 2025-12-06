import SwiftUI
import GameFrameIOSShared

/**
 * A view that displays a threaded comment section for a specific transcript/key moment.
 *
 * This view lets users:
 * - See a list of existing comments and their replies.
 * - Add new top-level comments.
 * - Reply inline to existing comments.
 *
 * ## Threading Behavior:
 * - Top-level comments are those with no `parentCommentId` or an empty `parentCommentId`.
 * - Replies are grouped under their parent comment and displayed with indentation.
 *
 * ## Data Flow:
 * - Comments are loaded via `viewModel.loadCommentsForTranscript(...)` when the view appears.
 * - New comments and replies are submitted via `viewModel.addComment(...)` and `viewModel.addReply(...)`.
 *
 * ## Usage:
 * - Embed this view within a screen that has access to a `CommentSectionViewModel`.
 * - Provide `teamDocId`, `keyMomentId`, `gameId`, and `transcriptId` to scope the comments
 *   to the appropriate team document and transcript.
 */
struct CommentSectionView: View {
    /// View model responsible for loading, storing, and updating the list of comments.
    @ObservedObject var viewModel: CommentSectionViewModel

    /// Holds the text for a new top-level comment being composed in the bottom input bar.
    @State private var newComment: String = ""

    /// Holds the text for a reply being composed inline under a specific parent comment.
    @State private var replyText: String = ""

    /// Tracks the `commentId` of the parent comment that is currently being replied to.
    /// If `nil`, no inline reply composer is visible.
    @State private var replyingToId: String? = nil   // which parent is being replied to

    /// Identifier for the team document associated with these comments.
    var teamDocId: String
    /// Identifier for the key moment associated with these comments.
    var keyMomentId: String
    /// Identifier for the game associated with these comments.
    var gameId: String
    /// Identifier for the transcript associated with these comments.
    var transcriptId: String

    /// Dependency container injected from the environment, used to configure the view model.
    @EnvironmentObject private var dependencies: DependencyContainer

    // MARK: - Thread helpers (keeps body simple)

    /// All top-level (root) comments that do not have a `parentCommentId`.
    /// These are sorted by creation date in ascending order (oldest first).
    private var roots: [DBComment] {
        viewModel.comments
            .filter { ($0.parentCommentId?.isEmpty ?? true) }
            .sorted { $0.createdAt < $1.createdAt }
    }

    /// Dictionary mapping a parent `commentId` to its direct replies.
    /// Only comments that have a non-empty `parentCommentId` are included.
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
            // Section title
            Text("Comments")
                .font(.headline)
                .padding(.horizontal)
                .padding(.top)

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    // Empty state when there are no comments yet.
                    if viewModel.comments.isEmpty {
                        Text("No comments yet. Be the first to comment!")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 8)
                    } else {
                        // List of threaded comments.
                        ForEach(roots, id: \.commentId) { parent in
                            // Parent (top-level) comment row.
                            CommentRow(comment: parent)

                            // Button that toggles the inline reply composer for this parent.
                            Button("Reply") { replyingToId = parent.commentId }
                                .font(.caption)
                                .foregroundColor(.blue)
                                .buttonStyle(.plain)
                                .padding(.leading, 44)

                            // Inline reply composer for this specific parent comment.
                            if replyingToId == parent.commentId {
                                replyComposer(parentId: parent.commentId)
                                    .padding(.horizontal)
                            }

                            // Replies for this parent (indented).
                            if let replies = repliesByParent[parent.commentId] {
                                ForEach(replies.sorted { $0.createdAt < $1.createdAt }, id: \.commentId) { reply in
                                    CommentRow(comment: reply)
                                        .padding(.leading, 40)
                                }
                            }

                            // Divider between threads.
                            Divider().padding(.leading, 16)
                        }
                    }
                }
                .padding(.horizontal)
                // .padding(.bottom, 96) // space so last row isn't covered by input bar (if needed)
            }
        }
        // Bottom input bar for creating new top-level comments, inset into the safe area.
        .safeAreaInset(edge: .bottom) {
            inputBar
                .ignoresSafeArea(.keyboard, edges: .bottom)
                .zIndex(1000)
        } // main comment composer
        // Load comments for the given transcript when the view appears.
        .task {
            await viewModel.loadCommentsForTranscript(teamDocId: teamDocId, transcriptId: transcriptId)
        }
        .onAppear {
            // Inject shared dependencies into the view model.
            viewModel.setDependencies(dependencies)
        }
    }

    // MARK: - Inline reply composer

    /**
     * Builds the inline reply composer UI for a given parent comment.
     *
     * - Parameter parentId: The `commentId` of the comment being replied to.
     *
     * The reply is sent via `viewModel.addReply(...)` and the local state is cleared upon success.
     */
    @ViewBuilder
    private func replyComposer(parentId: String) -> some View {
        HStack(spacing: 8) {
            // Text field where the user types their reply.
            TextField("Write a reply…", text: $replyText)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(.separator), lineWidth: 1)
                        )
                )

            // Send button for the reply.
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

                    // Reset reply state after sending.
                    replyText = ""
                    replyingToId = nil
                }
            } label: {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(
                        replyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        ? .gray
                        : .red
                    )
            }
            .disabled(replyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }

    // MARK: - Bottom input bar (new top-level comment)

    /// Input bar shown at the bottom of the screen for creating new top-level comments.
    /// Uses `newComment` as the bound text and calls `viewModel.addComment(...)` when sending.
    private var inputBar: some View {
        VStack(spacing: 0) {
            // Small white spacer above the input bar to visually separate it from the content.
            Color.white.frame(height: 12)

            HStack(spacing: 8) {
                // Text field for typing a new top-level comment.
                TextField("Write a comment…", text: $newComment)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(.separator), lineWidth: 1)
                            )
                    )

                // Send button for the new comment.
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

                        // Clear composer after sending.
                        newComment = ""
                    }
                } label: {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(
                            newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? .gray
                            : .red
                        )
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

// MARK: - Small reusable row

/// A single comment row displaying the author, timestamp, and comment text.
/// Used for both top-level comments and replies.
private struct CommentRow: View {
    /// The comment model to display.
    let comment: DBComment

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            // Placeholder avatar icon.
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(.gray)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    // Username / author of the comment.
                    Text(comment.uploadedBy)
                        .font(.subheadline)
                        .bold()

                    Spacer()

                    // Time the comment was created, formatted as hour:minute.
                    Text(comment.createdAt.formatted(.dateTime.hour().minute()))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Comment text bubble.
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
