//
//  NavigationReducer.swift
//  BusinessCard
//
//  Created by Luke Street on 9/17/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import Redux
import Combine

func navigation(
    _ reducer: @escaping Reducer<App.State, App.Action>
) -> Reducer<App.State, App.Action> {
    return { state, action in
        let effects = reducer(&state, action)
        switch action {
        case .create(.cancel):
//            state.createCardState = nil
            return [Just(.showCreateCard(nil)).eraseToEffect()] + effects
        case .create(.done):
//            return [Just(.showCreateCard(nil)).eraseToEffect()] + effects
            state.createCardState = nil
        case .cards(.detail(.edit(let card))):
//            state.cardsState.detailCardID = nil
//            state.createCardState = .init(card: card)
            return [Just(.showCreateCard(CreateCardState(card: card))).eraseToEffect()] + effects
        case .cards(.detail(.share(let card))):
            return [Just(.cards(.share(card.id))).eraseToEffect()] + effects
        case .cards: break
        case .create: break
        case .updateCreateCardState: break
        case .confirmCreateCardCancel: break
        case .showCreateCard(let createCardState):
            state.createCardState = createCardState
        }
        return effects
    }
}
