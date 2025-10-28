//
//  DependencyContainer.swift
//  GameFrameIOSShared
//
//  Created by Mélina Rochon on 2025-10-25.
//

import Foundation
import Combine
import GameFrameIOSShared

public final class DependencyContainer: ObservableObject {
    @Published public var authenticationManager: AuthenticationManager
    public let userManager: UserManager
    public let userRepository: UserRepository
    public let coachManager: CoachManager
    public let teamManager: TeamManager
    public let inviteManager: InviteManager
    public let playerManager: PlayerManager
    public let playerTeamInfoManager: PlayerTeamInfoManager
    public let fullGameRecordingManager: FullGameVideoRecordingManager
    public let gameManager: GameManager
    public let keyMomentManager: KeyMomentManager
    public let transcriptManager: TranscriptManager
    public let teamMembershipManager: TeamMembershipPlanManager
    public let commentManager: CommentManager
    
    public init(useLocalRepositories: Bool) {
        if useLocalRepositories {
            print("⚠️ Using Local Repositories (Firebase disabled)")
            authenticationManager = AuthenticationManager(repo: LocalAuthenticationRepository())
            userManager = UserManager(repo: LocalUserRepository())
            userRepository = LocalUserRepository()
            coachManager = CoachManager(repo: LocalCoachRepository())
            teamManager = TeamManager(repo: LocalTeamRepository())
            inviteManager = InviteManager(repo: LocalInviteRepository())
            playerManager = PlayerManager(repo: LocalPlayerRepository())
            playerTeamInfoManager = PlayerTeamInfoManager(repo: LocalPlayerTeamInfoRepository())
            fullGameRecordingManager = FullGameVideoRecordingManager(repo: LocalFullGameRecordingRepository())
            gameManager = GameManager(repo: LocalGameRepository())
            keyMomentManager = KeyMomentManager(repo: LocalKeyMomentRepository())
            transcriptManager = TranscriptManager(repo: LocalTranscriptRepository())
            teamMembershipManager = TeamMembershipPlanManager(repo: LocalTeamMembershipPlanRepository())
            commentManager = CommentManager(repo: LocalCommentRepository())
        }
        else {
            print("Using Firestore Repositories (Firebase disabled)")
            authenticationManager = AuthenticationManager(repo: FirestoreAuthenticationRepository())
            userManager = UserManager(repo: FirestoreUserRepository())
            userRepository = FirestoreUserRepository()
            coachManager = CoachManager(repo: FirestoreCoachRepository())
            teamManager = TeamManager(repo: FirestoreTeamRepository())
            inviteManager = InviteManager(repo: FirestoreInviteRepository())
            playerManager = PlayerManager(repo: FirestorePlayerRepository())
            playerTeamInfoManager = PlayerTeamInfoManager(repo: FirestorePlayerTeamInfoRepository())
            fullGameRecordingManager = FullGameVideoRecordingManager(repo: FirestoreFullGameVideoRecordingRepository())
            gameManager = GameManager(repo: FirestoreGameRepository())
            keyMomentManager = KeyMomentManager(repo: FirestoreKeyMomentRepository())
            transcriptManager = TranscriptManager(repo: FirestoreTranscriptRepository())
            teamMembershipManager = TeamMembershipPlanManager(repo: FirestoreTeamMembershipPlanRepository())
            commentManager = CommentManager(repo: FirestoreCommentRepository())
        }
    }
}
