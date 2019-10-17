//
//  Card+Extensions.swift
//  App
//
//  Created by Luke Street on 9/28/19.
//

import Models
import Fluent
import Vapor

final class CardModel: Model, Content {
    
    @ID(key: "id")
    var id: UUID?
    
    init() { card = .init() }
    
    typealias IDValue = UUID
    
    static var schema = "cards"
    
    @Field(key: "card")
    var card: Card
    
    init(card: Card) {
        self.card = card
    }
}
