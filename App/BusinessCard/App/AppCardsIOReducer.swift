//
//  CardsIOReducer.swift
//  BusinessCard
//
//  Created by Luke Street on 9/17/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import ComposableArchitecture
import Combine

extension Reducer where State == App.State, Action == App.Action, Environment == App.Environment {
    func cardsIO() -> Self {
        return .init { state, action, environment in
            let effects = self(&state, action, environment)
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
    
    func navigation() -> Self {
        return .init { state, action, environment in
            let effects = self(&state, action, environment)
            switch action {
            case .create(.cancel):
                return Just(.showCreateCard(nil)).merge(with: effects).eraseToEffect()
            case .create(.done):
                state.createCardState = nil
            case .cards(.detail(_, .edit(let card))):
                return Just(.showCreateCard(.init(card: card)))
                    .eraseToEffect()
                    .merge(with: effects)
                    .eraseToEffect()
            case .cards(.detail(_, .share(let card))):
                return Just(.cards(.share(card.id)))
                    .eraseToEffect()
                    .merge(with: effects)
                    .eraseToEffect()
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

}
