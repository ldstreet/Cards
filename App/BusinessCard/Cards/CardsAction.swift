//
//  Cards.Action.swift
//  BusinessCard
//
//  Created by Luke Street on 9/1/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import Foundation

extension Cards {
    enum Action {
        case delete(UUID)
        case proposeCardDelete(UUID?)
        case share(UUID)
        case presentShareLink(URL)
    }
}

