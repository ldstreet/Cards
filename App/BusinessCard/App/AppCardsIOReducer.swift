//
//  CardsIOReducer.swift
//  BusinessCard
//
//  Created by Luke Street on 9/17/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import Redux

func cardsIO(
    _ reducer: @escaping Reducer<App.State, App.Action, App.Environment>
) -> Reducer<App.State, App.Action, App.Environment> {
    return { state, action, environment in
        let effects = reducer(&state, action, environment)
        switch action {
        case .cards(_): break
        case .create(.done):
            guard let card = state.createCardState?.card else { return effects }
            if let existingIndex = state.cardsState.cards.firstIndex(where: { $0.id == state.createCardState?.card.id }) {
                state.cardsState.cards[existingIndex] = card
            } else {
                state.cardsState.cards.append(card)
            }
            state.createCardState = .init(card: .createDefaultCard())
            
        case .create(_): break
        case .updateCreateCardState(_): break
        case .showCreateCard(_): break
        case .confirmCreateCardCancel(_): break
        }
        return effects
    }
}
