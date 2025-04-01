//
//  GameDTO.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-11.
//

import Foundation

/**
 A Data Transfer Object (DTO) used to represent a home game, containing details about the game and the associated team.

 - `game`: An instance of `DBGame`, which represents the game details, such as the date, score, or game-specific information stored in the database.
 - `team`: An instance of `DBTeam`, which represents the team details, such as team name, players, and other team-specific information stored in the database.
 
 This DTO is typically used to transfer relevant information about a home game between different layers of the application, such as from the database to the view or business logic layers.
 */
struct HomeGameDTO {
    let game: DBGame
    let team: DBTeam
}
