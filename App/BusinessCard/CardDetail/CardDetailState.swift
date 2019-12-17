//
//  CardDetailState.swift
//  BusinessCard
//
//  Created by Luke Street on 10/30/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import Foundation
import Models

extension CardDetail {
    
    public struct State: Equatable {
        var card: Card
        
        public init(card: Card) {
            self.card = card
        }
    }
}
