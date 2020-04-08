//
//  CardDetailReducer.swift
//  BusinessCard
//
//  Created by Luke Street on 10/30/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import Redux
import Models
import Combine

extension CardDetail {
    
    static let reducer: Reducer<State, Action, Environment> = { state, action, environment in
        switch action {
        case .edit: break
        case .share: break
        }
        
        return []
    }
    
}
