//
//  Reducer.swift
//  BusinessCard
//
//  Created by Luke Street on 9/17/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import Foundation

extension App {
    static let _reducer: Reducer<App.State, App.Action> = { state, action in
        switch action {
        case .cards(_): break
        case .create(_): break
        case .updateCreateCardState(let createCardState):
            state.createCardState = createCardState
        case .confirmCreateCardCancel(let show):
    //        state.createCardState = .init(card: .createDefaultCard())
            state.showCreateCardCancelDialog = show
        case .showCreateCard(let show):
            state.showCreateCard = show
        }
    }
    
    static let reducer: Reducer<App.State, App.Action> = combine(
        ._reducer,
        pullback(
            Cards.reducer,
            value: \App.State.cardsState,
            action: \App.Action.cards
        ),
        pullback(
            createCardReducer,
            value: \App.State.createCardState,
            action: \App.Action.create
        )
    )
}
