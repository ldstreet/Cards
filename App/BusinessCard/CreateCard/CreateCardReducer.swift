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
    static let reducer: Reducer<State, Action> = { state, action in
        switch action {
        case .firstNameChanged(let str):
            state.card.firstName = str
        case .lastNameChanged(let str):
            state.card.lastName = str
        case .titleChanged(let str):
            state.card.title = str
        case .fieldChanged(let value, let indexPath):
            state.card.fields.groups[indexPath.section].fields[indexPath.item].value = value
        case .fieldSpecifierChanged(let specifierIndex, let indexPath):
            state.card.fields.groups[indexPath.section].fields[indexPath.item].specifierIndex = specifierIndex
        case .cancel: break
        case .done: break
        }
        return []
    }
}
