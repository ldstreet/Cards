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
    struct State: Codable, Equatable {
        var cards: [Card] = []
        var detailCardID: UUID?
        var detailCard: CardDetail.State? {
            get {
                cards.first(where: { $0.id == detailCardID }).map(CardDetail.State.init)
            }
            set {
                if let index = cards.firstIndex(where: { $0.id == detailCardID }),
                    let newCard = newValue {
                    cards[index] = newCard.card
                } else  {
                    detailCardID = nil
                }
            }
        }
        var showConfirmDelete = false
        var proposedCardDeleteID: UUID?
        var error: CardsError?
        var createCardState: CreateCardState?
        var loading = false
        var shareLink: URL? = nil
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
