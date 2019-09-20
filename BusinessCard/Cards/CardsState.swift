//
//  CardsState.swift
//  BusinessCard
//
//  Created by Luke Street on 9/1/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import Foundation

extension Cards {
    struct State: Codable {
        var cards: [Card] = []
    }
}
