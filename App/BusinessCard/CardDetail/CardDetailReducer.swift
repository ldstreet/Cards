//
//  CardDetailReducer.swift
//  BusinessCard
//
//  Created by Luke Street on 10/30/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import ComposableArchitecture
import Models
import Combine

extension CardDetail {
    
    static let reducer: Reducer<State, Action, Environment> = .init { state, action, environment in
        switch action {
        case .edit: break
        case .share: break
        }
        
        return .none
    }
    
}
