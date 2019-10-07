//
//  Card+Extensions.swift
//  App
//
//  Created by Luke Street on 9/28/19.
//

import Models
import FluentSQLite

extension Card: Model {
    
    public var fluentID: UUID? {
        get { return id }
        set { self.id = newValue ?? self.id }
    }
    
    public typealias Database = SQLiteDatabase
    
    public static var idKey: WritableKeyPath<Card, UUID?> {
        return \.fluentID
    }
    
    
}
