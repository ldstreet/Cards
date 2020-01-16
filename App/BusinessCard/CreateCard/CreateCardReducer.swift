//
//  CreateCardReducer.swift
//  BusinessCard
//
//  Created by Luke Street on 12/17/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import Foundation
import Redux

extension CreateCard {
    private static let _reducer: Reducer<State, Action> = { state, action in
        switch action {
        case .firstNameChanged(let str):
            state.card.firstName = str
        case .lastNameChanged(let str):
            state.card.lastName = str
        case .titleChanged(let str):
            state.card.title = str
        case .groups: break
        case .cancel: break
        case .done: break
        }
        return []
    }
    
    static let reducer: Reducer<State, Action> = combine(
        _reducer,
        indexed(
            reducer: FieldGroup.reducer,
            \State.card.groups,
            \Action.groups
        )
    )
    
    
}
