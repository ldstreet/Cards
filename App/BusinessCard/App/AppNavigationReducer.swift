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
        let effectPublisher = reducer(&state, action)()
        switch action {
        case .create(.cancel):
            state.showCreateCard = false
            state.createCardState = .init(card: .createDefaultCard())
        case .create(.done):
            state.showCreateCard = false
        case .cards(.detail(.edit(let card))):
            state.showCreateCard = true
            state.createCardState = .init(card: card)
        case .cards(.detail(.share(let id))):
            return { Just(.cards(.share(id))).eraseToAnyPublisher() }
        case .cards: break
        case .create: break
        case .updateCreateCardState: break
        case .confirmCreateCardCancel: break
        case .showCreateCard: break
        }
        return { effectPublisher }
    }
}
