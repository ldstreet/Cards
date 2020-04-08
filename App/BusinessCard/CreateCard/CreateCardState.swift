//
//  CreateCardState.swift
//  BusinessCard
//
//  Created by Luke Street on 12/17/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import Foundation
import Models

extension CreateCard {
    struct State: Codable, Identifiable, Equatable {
        let id = UUID()
        var card = Card.createDefaultCard()
        var showCameraImport = false
    }
}
