//
//  CardsState.swift
//  BusinessCard
//
//  Created by Luke Street on 9/1/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import Foundation
import Models

extension Cards {
    struct State: Codable {
        var cards: [Card] = []
        var showConfirmDelete = false
        var proposedCardDeleteID: UUID?
        var loading = false
        var shareLink: URL?
        var error: CardsError?
    }
}

enum CardsError: String, LocalizedError, Codable {
    case invalidLink
    
    var localizedDescription: String {
        switch self {
        case .invalidLink: return "There was an error fetching your share link."
        }
    }
}
