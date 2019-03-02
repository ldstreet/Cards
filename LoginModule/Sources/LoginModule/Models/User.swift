//
//  UserToken.swift
//  App
//
//  Created by Luke Street on 2/16/19.
//

import Foundation

/// A registered user, capable of owning todo items.
final public class User: Codable {
    /// User's unique identifier.
    /// Can be `nil` if the user has not been saved yet.
    public var id: Int?
    
    /// User's full name.
    public var name: String
    
    /// User's email address.
    public var email: String
    
    /// BCrypt hash of the user's password.
    public var passwordHash: String
    
    /// Creates a new `User`.
    public init(id: Int? = nil, name: String, email: String, passwordHash: String) {
        self.id = id
        self.name = name
        self.email = email
        self.passwordHash = passwordHash
    }
}
