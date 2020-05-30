//
//  Reducer.swift
//  BusinessCard
//
//  Created by Luke Street on 9/17/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import ComposableArchitecture

extension App {
    static let _reducer: Reducer<App.State, App.Action, App.Environment> = .init { state, action, environment in
        switch action {
        case .cards(_): break
        case .create(_): break
        case .updateCreateCardState(let createCardState):
            state.createCardState = createCardState
        case .confirmCreateCardCancel(let card):
            state.showCreateCardCancelDialog = card
            if card != nil && state.createCardState?.card.hasBeenChanged == true {
                state.showCreateCardCancelDialog = card
            } else {
                state.showCreateCardCancelDialog = nil
            }
            
        case .showCreateCard(let cardState):
            state.createCardState = cardState
        }
        return .none
    }
    
    static let reducer = Reducer<App.State, App.Action, App.Environment>.combine(
        App._reducer,
        Cards.reducer.pullback(
            state: \App.State.cardsState,
            action: /App.Action.cards,
            environment: { _ in Cards.Environment() }
        ),
        CreateCard.reducer.optional.pullback(
            state: \App.State.createCardState,
            action: /App.Action.create,
            environment: { _ in .init() }
        )
//        CardDetail.reducer.optional.pullback(
//            state: \App.State.cardsState.detailCard,
//            action: /App.Action.cards..Cards.Action.detail,
//            environment: { _ in .init() }
//        )
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
