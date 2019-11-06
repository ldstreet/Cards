//
//  CardDetailReducer.swift
//  BusinessCard
//
//  Created by Luke Street on 10/30/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import Redux

extension CardDetail {
    
    static let reducer: Reducer<State, Action> = { state, action in
        switch action {
        case .edit: break
        case .share: break
        }
        return { .empty() }
    }
    
}