//
//  App.State.swift
//  BusinessCard
//
//  Created by Luke Street on 9/17/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import Foundation
import Models

extension App {
    struct State: Codable, Equatable {
        var cardsState: Cards.State = .init()
        var createCardState: CreateCardState?
        var showCreateCardCancelDialog: Card?
    }
}

