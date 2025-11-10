//
//  CoachSpecificTranscriptView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-02-05.
//

import SwiftUI
import UIKit
import CoreTransferable
import GameFrameIOSShared

/// `CoachSpecificTranscriptView` displays details for a specific transcript from a game.
/// It shows game information, transcript text, associated players, and comments.
struct CoachSpecificTranscriptView: View {
    
    /// State variable to track whether the edit mode is active.
    @State private var isEditing: Bool = false
    
    /// View model responsible for handling comments.
    @StateObject private var commentViewModel = CommentSectionViewModel()
    
    /// View model responsible for handling transcript-related operations.
    @StateObject private var transcriptModel = TranscriptModel()
    @EnvironmentObject private var dependencies: DependencyContainer

    /// The game associated with the transcript.
    @State var game: DBGame
    
    /// The team associated with the game.
    @State var team: DBTeam
    
    /// The specific transcript being displayed.
    @State var transcript: keyMomentTranscript?

    /// Stores player details for whom feedback is provided in this transcript.
    @State private var feedbackFor: [PlayerNameAndPhoto] = []
    
    /// Stores the editable transcript text when in edit mode.
    @State private var feedbackTranscript: String = ""
    
    /// Stores all players mapped into a feedback structure with selection state.
    @State private var playersFeedback: [PlayerFeedback] = []
    
    @State private var originalTranscriptText: String = ""
    @State private var originalSelectedPlayers: [String] = []

    private var hasChanges: Bool {
        let currentSelectedPlayers = playersFeedback.filter { $0.isSelected }.map { $0.id }
        let samePlayers = Set(currentSelectedPlayers) == Set(originalSelectedPlayers)
        let sameTranscript = feedbackTranscript == originalTranscriptText
        
        return !(samePlayers && sameTranscript)
    }
    @State private var isInitialLoadComplete = false


    /// Whether the associated audio file has been downloaded and is available for playback.
    @State private var audioFileRetrieved: Bool = false

    /// Tracks whether transcript text is being edited separately.
    @State private var editTranscript: Bool = false

    /// View model responsible for fetching player information.
    @StateObject private var playerModel = PlayerModel()
    
    /// Allows dismissing the view to return to the previous screen
    @Environment(\.dismiss) var dismiss
    
    @State private var dismissOnRemove: Bool = false
    
    var body: some View {
        NavigationView {
            ScrollView {
//                ShareButton(content:
                                VStack {
                    
                    // Game title and transcript information section.
                    VStack(alignment: .leading) {
                        HStack {
                            Text(game.title).font(.title2)
                            Spacer()
                        }
                                                
                        // Displays team name and transcript creation time.
                        HStack {
                            VStack(alignment: .leading) {
                                Text(team.name)
                                    .font(.subheadline)
                                    .foregroundStyle(.black.opacity(0.9))
                                if let transcript = transcript {
                                    Text(transcript.frameStart.formatted(.dateTime.year().month().day().hour().minute()))
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 3)
                    
                    Divider().padding(.vertical, 2)
                    
                    if let transcript = transcript {
                        // Displays the transcript text along with its timestamp relative to game start.
                        VStack(alignment: .leading) {
                            
                            if audioFileRetrieved {
                                let localAudioURL = FileManager.default
                                    .urls(for: .documentDirectory, in: .userDomainMask)[0]
                                    .appendingPathComponent("downloaded_audio.m4a")
                                
                                AudioPlayerView(audioURL: localAudioURL)
                            }
                            
                            if let gameStartTime = game.startTime {
                                let durationInSeconds = transcript.frameStart.timeIntervalSince(gameStartTime)
                                Text(formatDuration(durationInSeconds))
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                                    .padding(.bottom, 2)
                                
                                Text(transcript.transcript)
                                    .font(.caption)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.vertical, 10)
                        
                        // Feedback for Section
                        VStack(alignment: .leading) {
                            Text("Feedback For")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack {
                                Text(feedbackFor.map { $0.name }.joined(separator: ", "))
                                    .font(.caption)
                                    .padding(.top, 2)
                            }
                            .multilineTextAlignment(.leading)
                        }.padding(.horizontal).padding(.vertical, 10)
                        
                        VStack {
                            Divider()
                            // Comment section allowing users to view and add comments for the transcript.
                            CommentSectionView(
                                viewModel: commentViewModel,
                                teamDocId: team.id,
                                keyMomentId: "\(transcript.keyMomentId)",
                                gameId: game.gameId,
                                transcriptId: "\(transcript.transcriptId)"
                            )
                        }
                        .frame(maxHeight: .infinity, alignment: .bottom)
                    }
                }
                //                )
            }
            .safeAreaInset(edge: .bottom){ // Adding padding space for nav bar
                Color.clear.frame(height: 75)
            }
            .task {
                do {
                    print("CoachSpecificTranscript, teamDocId: \(team.id)")
                    
                    if let transcript = transcript {
                        if !isEditing
                        {
                            let feedback = transcript.feedbackFor ?? []
                            
                            // Add a new key moment to the database
                            let fbFor: [String] = feedback.map { $0.playerId }
                            feedbackFor = try await transcriptModel.getFeebackFor(feedbackFor: fbFor)
                            feedbackTranscript = transcript.transcript
                        }
                    }
                } catch {
                    print("Error when fetching specific footage info: \(error)")
                }
            }
            .onChange(of: dismissOnRemove) { newValue in
                // Remove transcript from database
                Task {
                    do {
                        if let transcript = transcript {
                            try await transcriptModel.removeTranscript(gameId: game.gameId, teamId: team.teamId, transcriptId: transcript.transcriptId, keyMomentId: transcript.keyMomentId)
                            dismiss()
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
            .sheet(isPresented: $isEditing) {
                if let transcript = transcript {
                    NavigationView {
                        FeedbackForView(dismissOnRemove: $dismissOnRemove, allPlayers: team.players, feedbackTranscript: $feedbackTranscript, playersFeedback: $playersFeedback)
                            .toolbar {
                                ToolbarItem(placement: .topBarLeading) {
                                    Button(action: {
                                        resetData()
                                        isInitialLoadComplete = false
                                        isEditing = false // Dismiss the full-screen cover
                                    }) {
                                        Text("Cancel")
                                    }
                                }
                                
                                ToolbarItem(placement: .topBarTrailing) {
                                    Button(action: {
                                        saveData()
                                        isInitialLoadComplete = false
                                        isEditing = false // Dismiss the full-screen cover
                                    }) {
                                        Text("Save")
                                    }
                                    .disabled(!hasChanges || !isInitialLoadComplete)
                                }
                            }
                            .task {
                                do {

                                    if let allPlayers = team.players {
                                        print("getting all players = \(allPlayers)")
                                        let players = try await playerModel.getAllPlayersNamesAndUrl(players: allPlayers)
                                        // Map to include selection state
                                        playersFeedback = players.map { (id, name, photoUrl) in
                                            let isSelected = feedbackFor.contains { $0.playerId == id }
                                            return PlayerFeedback(id: id, name: name, photoUrl: photoUrl, isSelected: isSelected)
                                        }
                                    }
                                    
                                    originalTranscriptText = feedbackTranscript
                                    originalSelectedPlayers = feedbackFor.map { $0.playerId }
                                    isInitialLoadComplete = true

                                } catch {
                                    print("Error when fetching specific footage info: \(error)")
                                }
                            }
                    }
                }
            }
            .onAppear {
                transcriptModel.setDependencies(dependencies)
                commentViewModel.setDependencies(dependencies)
                playerModel.setDependencies(dependencies)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if !isEditing {
                    Button {
                        withAnimation {
                            isEditing.toggle()
                        }
                    } label: {
                        Text("Edit")
                    }
                    .frame(width: 40)
                    .foregroundColor(.red)
                }
            }
        }
        .task {
            // Fetch the audio url
            if let transcript = transcript {
                do {
                    let audioURL = try await transcriptModel.getAudioFileUrl(keyMomentId: transcript.keyMomentId, gameId: game.gameId, teamId: team.teamId)
                    
                    if let url = audioURL {
                        // Fetch audio file from db
                        let storageRef = StorageManager.shared.getAudioURL(path: url)
                        
                        let localURL = FileManager.default
                            .urls(for: .documentDirectory, in: .userDomainMask)[0]
                            .appendingPathComponent("downloaded_audio.m4a")
                        
                        storageRef.write(toFile: localURL) { url, error in
                            if let error = error {
                                print("❌ Failed to download audio: \(error.localizedDescription)")
                            } else {
                                print("✅ Audio downloaded to: \(url?.path ?? "")")
                                // You can now use this local file (e.g., to play it)
                                audioFileRetrieved = true
                            }
                        }
                    }
                } catch {
                    print("ERROR WHEN fetching AUDIO url: \(error)")
                }
            }
        }
    }
    
    
    /// Saves the updated transcript data to Firestore.
    ///
    /// - Updates `feedbackFor` with the players that were selected in the UI.
    /// - Persists transcript text and feedbackFor players to the database.
    /// - Updates the local transcript state with the edited values.
    ///
    /// Errors are caught and logged if saving fails.
    private func saveData() {
        Task {
            do {
                feedbackFor = playersFeedback
                    .filter { $0.isSelected }
                    .map { PlayerNameAndPhoto(playerId: $0.id, name: $0.name, photoURL: $0.photoUrl) }
                
                if let transcript = transcript {
                    try await transcriptModel.updateTranscriptInfo(teamDocId: team.id, teamId: team.teamId, gameId: game.gameId, transcriptId: transcript.transcriptId, feedbackFor: feedbackFor, transcript: feedbackTranscript)
                }
                
                playersFeedback = []
                transcript?.transcript = feedbackTranscript
                
            } catch {
                // Print error message if saving data fails
                print("Error occurred when saving the transcript data: \(error.localizedDescription)")
            }
        }
    }
    
    
    /// Resets the feedback transcript text field to the original transcript content.
    ///
    /// - If `transcript` exists, it restores `feedbackTranscript` with its value.
    /// - If `transcript` is `nil`, it resets to an empty string.
    private func resetData() {
        feedbackTranscript = transcript?.transcript ?? ""
    }
}


/// Represents a player with associated feedback selection state.
struct PlayerFeedback: Identifiable, Equatable {
    /// The player’s unique ID.
    let id: String
    /// Full display name of the player.
    var name: String
    /// Optional profile photo URL of the player.
    let photoUrl: URL?
    /// Whether this player has been selected for feedback.
    var isSelected: Bool
}


/// A view for editing feedback players and transcript text.
struct FeedbackForView: View {
    
    @Binding var dismissOnRemove: Bool
    
    /// All player IDs available in the team.
    @State var allPlayers: [String]?
    
    /// Binding to the editable transcript text.
    @Binding var feedbackTranscript: String
    
    /// Binding to the list of players with feedback selection state.
    @Binding var playersFeedback: [PlayerFeedback]
    
    /// Transcript model used for fetching and updating transcript data.
    @StateObject private var transcriptModel = TranscriptModel()
    @EnvironmentObject private var dependencies: DependencyContainer

    /// Allows dismissing the view to return to the previous screen
    @Environment(\.dismiss) var dismiss
    
    @State private var confirmationShow: Bool = false
    
    var body: some View {
        VStack {
            Form {
                Section (header: Text("Transcript")) {
                    TextField("Enter your text", text: $feedbackTranscript, axis: .vertical)
                        .lineLimit(5)
                }
                
                Section(header: Text("Selected Players")) {
                    ForEach(playersFeedback.indices.filter { playersFeedback[$0].isSelected }, id: \.self) { index in
                        CheckboxRow(title: playersFeedback[index].name,
                                    isChecked: $playersFeedback[index].isSelected)
                    }
                }
                
                Section(header: Text("Other Players")) {
                    ForEach(playersFeedback.indices.filter { !playersFeedback[$0].isSelected }, id: \.self) { index in
                        CheckboxRow(title: playersFeedback[index].name,
                                    isChecked: $playersFeedback[index].isSelected)
                    }
                }
                
                Section {
                    Button(role: .destructive, action: {
                        confirmationShow = true
                        
                    }) {
                        Text("Delete")
                    }
                }
            }
        }
        .confirmationDialog(
            "Are you sure you want to delete this feedback? This will remove the transcript and its associated key moment. This action cannot be undone.",
            isPresented: $confirmationShow,
            titleVisibility: .visible
        ) {
            Button(role: .destructive, action: {
                dismiss()
                dismissOnRemove = true
            }) {
                Text("Delete")
            }
        }
        .onAppear {
            transcriptModel.setDependencies(dependencies)
        }
    }
}


/// A row with a player’s name and a checkmark toggle for feedback selection.
struct CheckboxRow: View {
    
    /// Display name of the player.
    let title: String
    
    /// Whether the checkbox is selected.
    @Binding var isChecked: Bool
    
    var body: some View {
        Button {
            withAnimation {
                isChecked.toggle()
            }
        } label: {
            HStack {
                Image(systemName: isChecked ? "minus.circle.fill" : "plus.circle.fill")
                    .foregroundColor(isChecked ? .red : .green)
                Text(title)
                    .foregroundColor(.primary)
                Spacer()
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let team = DBTeam(id: "123", teamId: "team-123", name: "Testing Team", teamNickname: "TEST", sport: "Soccer", gender: "Mixed", ageGrp: "Senior", coaches: ["FbhFGYxkp1YIJ360vPVLZtUSW193"])
    
    let game = DBGame(gameId: "game1", title: "Ottawa vs Toronto", duration: 1020, scheduledTimeReminder: 10, timeBeforeFeedback: 15, timeAfterFeedback: 15, recordingReminder: true, teamId: "team-123")
    NavigationStack {
        CoachSpecificTranscriptView(game: game, team: team, transcript: nil)
    }
}


extension View {
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view

        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}


struct ShareButton<Content: View>: View {
    let content: Content
    @State private var isSharing = false
    @State private var image: UIImage?

    var body: some View {
        VStack {
            content

            Button {
                image = content.snapshot()
                isSharing = true
            } label: {
                Label("Share Page", systemImage: "square.and.arrow.up")
            }
            .padding()
            .sheet(isPresented: $isSharing) {
                if let image = image {
                    ActivityView(activityItems: [image])
                }
            }
        }
    }
}

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
