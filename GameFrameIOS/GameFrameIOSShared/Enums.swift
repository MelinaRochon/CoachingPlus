//
//  Enums.swift
//  GameFrameIOSShared
//
//  Created by Mélina Rochon on 2025-10-27.
//

import Foundation

public enum AuthError: Error {
    case invalidEmail
    case invalidPwd
    case invalidCredentials
    case noAuthenticatedUser
    case userNotFound
}

public enum DependencyError: Error {
    case noDependencyAvailable
}

public enum CoachError: Error {
    case coachNotFound
}

public enum CommentError: Error {
    case commentNotFound
}

public enum GameError: Error {
    case gameNotFound
}

public enum KeyMomentError: Error {
    case keyMomentNotFound
}

public enum PlayerError: Error {
    case playerNotFound
    case playerAlreadyAddedToTeam
}

public enum TeamError: Error {
    case teamNotFound
    case invalidAccessCode
    case playerAlreadyInTeam
    case coachAlreadyInTeam
    case inviteAlreadySent
    case inviteNotFound
}

public enum InviteError: Error {
    case inviteNotFound
    case invalidStatus
    case inviteAlreadyExistsForThisTeamId
    case errorWhenCreatingTeamInvite
    case teamInviteNotFound
}

public enum TranscriptError: Error {
    case transcriptNotFound
}


public enum UserError: Error {
    case userNotFound
    case userInvalidEmail
    case invalidUserName
}

public enum PlayerTeamInfoError: Error {
    case playerTeamInfoNotFound
}
