//
//  CardsIOReducer.swift
//  BusinessCard
//
//  Created by Luke Street on 9/17/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import Redux

func cardsIO(
    _ reducer: @escaping Reducer<App.State, App.Action>
) -> Reducer<App.State, App.Action> {
    return { state, action in
        let effectPublisher = reducer(&state, action)
        switch action {
        case .cards(_): break
        case .create(.done):
            if let existingIndex = state.cardsState.cards.firstIndex(where: { $0.id == state.createCardState.card.id }) {
                state.cardsState.cards[existingIndex] = state.createCardState.card
            } else {
                state.cardsState.cards.append(state.createCardState.card)
            }
            state.createCardState = .init(card: .createDefaultCard())
            
        case .create(_): break
        case .updateCreateCardState(_): break
        case .showCreateCard(_): break
        case .confirmCreateCardCancel(_): break
        }
        return { effectPublisher() }
    }
}
