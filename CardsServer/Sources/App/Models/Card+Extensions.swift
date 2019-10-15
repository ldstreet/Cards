//
//  Card+Extensions.swift
//  App
//
//  Created by Luke Street on 9/28/19.
//

import Models
import FluentPostgresDriver
import Vapor

final class CardModel: Model, Content {
    var id: UUID? {
        get {
            return card.id
        }
        set {
            card.id = newValue ?? card.id
        }
    }
    
    init() { card = .init() }
    
    typealias IDValue = UUID
    
    static var schema = "cards"
    
    
    var card: Card
    
    init(card: Card) {
        self.card = card
    }
}

//extension Card: Model {
//    
//    public var fluentID: UUID? {
//        get { return id }
//        set { self.id = newValue ?? self.id }
//    }
//    
//    public typealias Database = PostgreSQLDatabase
//    
//    public static var idKey: WritableKeyPath<Card, UUID?> {
//        return \.fluentID
//    }
//    
//    
//}
