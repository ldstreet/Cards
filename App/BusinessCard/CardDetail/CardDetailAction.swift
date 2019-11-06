//
//  CardDetailAction.swift
//  BusinessCard
//
//  Created by Luke Street on 10/30/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import Foundation
import Models

extension CardDetail {

    enum Action {
        case edit(Card)
        case share(UUID)
    }
    
}
