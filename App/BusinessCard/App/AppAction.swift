//
//  Action.swift
//  BusinessCard
//
//  Created by Luke Street on 9/17/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import Foundation
import Models

extension App {
    enum Action: Equatable {
        case cards(Cards.Action)
        case create(CreateCard.Action)
        case updateCreateCardState(CreateCard.State)
        case showCreateCard(CreateCard.State?)
        case confirmCreateCardCancel(Card?)
    }
}
