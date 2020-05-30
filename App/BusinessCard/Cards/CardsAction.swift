//
//  Cards.Action.swift
//  BusinessCard
//
//  Created by Luke Street on 9/1/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import Foundation

extension Cards {
    enum Action: Equatable {
        case delete(UUID)
        case proposeCardDelete(UUID?)
        case showDetail(UUID?)
        case detail(Int, CardDetail.Action)
        case share(UUID)
        case presentShareLink(URL?)
    }
}

