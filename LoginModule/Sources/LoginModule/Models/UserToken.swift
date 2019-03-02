//
//  UserToken.swift
//  App
//
//  Created by Luke Street on 2/16/19.
//

import Foundation

/// An ephermal authentication token that identifies a registered user.
final public class UserToken: Codable {
    
    /// UserToken's unique identifier.
    public var id: Int?
    
    /// Unique token string.
    public var string: String
    
    /// Reference to user that owns this token.
    public var userID: Int
    
    /// Expiration date. Token will no longer be valid after this point.
    public var expiresAt: Date?
    
    /// Creates a new `UserToken`.
    public init(id: Int? = nil, string: String, userID: Int) {
        self.id = id
        self.string = string
        // set token to expire after 5 hours
        self.expiresAt = Date.init(timeInterval: 60 * 60 * 5, since: .init())
        self.userID = userID
    }
}

/// Public representation of user data.
struct UserResponse: Codable {
    /// User's unique identifier.
    /// Not optional since we only return users that exist in the DB.
    let id: Int
    
    /// User's full name.
    let name: String
    
    /// User's email address.
    let email: String
}
