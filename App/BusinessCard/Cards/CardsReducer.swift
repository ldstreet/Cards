//
//  CardsReducer.swift
//  BusinessCard
//
//  Created by Luke Street on 9/1/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import Redux

extension Cards {
    static let reducer: Reducer<Cards.State, Cards.Action> = { state, action in
        switch action {
        case .delete(let id):
            state.cards.removeAll { $0.id == id }
        case .proposeCardDelete(let id):
            state.proposedCardDeleteID = id
            state.showConfirmDelete = id != nil
        }
    }
}
