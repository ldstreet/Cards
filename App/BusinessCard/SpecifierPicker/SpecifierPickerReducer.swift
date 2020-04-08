//
//  SpecifierPickerReducer.swift
//  BusinessCard
//
//  Created by Luke Street on 1/6/20.
//  Copyright © 2020 Luke Street. All rights reserved.
//

import Foundation
import Redux

extension SpecifierPicker {
    static let reducer: Reducer<State, Action, Environment> = { state, action, environment in
        switch action {
        case .selected(let index):
            state.selection = index
        }
        return []
    }
}
