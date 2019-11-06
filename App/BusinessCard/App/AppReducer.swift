//
//  Reducer.swift
//  BusinessCard
//
//  Created by Luke Street on 9/17/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import Redux

extension App {
    static let _reducer: Reducer<App.State, App.Action> = { state, action in
        switch action {
        case .cards(_): break
        case .create(_): break
        case .updateCreateCardState(let createCardState):
            state.createCardState = createCardState
        case .confirmCreateCardCancel(let show):
            state.showCreateCardCancelDialog = show
            if show == true && state.createCardState.card.hasBeenChanged {
                state.showCreateCardCancelDialog = true
            } else {
                state.showCreateCardCancelDialog = false
            }
            
        case .showCreateCard(let show):
            state.showCreateCard = show
        }
        return { .empty() }
    }
    
    static let reducer: Reducer<App.State, App.Action> = combine(
        App._reducer,
        pullback(
            Cards.reducer,
            value: \App.State.cardsState,
            action: \App.Action.cards
        ),
        pullback(
            createCardReducer,
            value: \App.State.createCardState,
            action: \App.Action.create
        ),
        pullback(
            CardDetail.reducer,
            value: \App.State.cardsState.detailCard,
            action: \App.Action.cards[optional: \.detail]
        )
    )
}

extension Optional {
    subscript<T>(optional path: WritableKeyPath<Wrapped, T>) -> T? {
        get {
            return self?[keyPath: path]
        }
        set {
            if let newValue = newValue {
                self?[keyPath: path] = newValue
            }
        }
    }
    
    subscript<T>(optional path: WritableKeyPath<Wrapped, T?>) -> T? {
        get {
            return self?[keyPath: path]
        }
        set {
            if let newValue = newValue {
                self?[keyPath: path] = newValue
            }
        }
    }
}
