//
//  App.State.swift
//  BusinessCard
//
//  Created by Luke Street on 9/17/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import Foundation

extension App {
    struct State: Codable {
        var cardsState: Cards.State = .init()
        var createCardState: CreateCardState = .init(card: .createDefaultCard())
        var showCreateCard = false
        var showCreateCardCancelDialog = false
        
        
    }
}

