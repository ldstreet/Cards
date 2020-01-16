//
//  Card.swift
//  CardsShare
//
//  Created by Luke Street on 6/14/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import Foundation

public typealias Value = Codable & Hashable & Equatable

public struct Card: Value, Identifiable {
    public var id: UUID
    public var firstName: String
    public var lastName: String
    public var title: String
    public var groups: [Group]
    
    public init(
        id: UUID = .init(),
        firstName: String = "",
        lastName: String = "",
        title: String = "",
        groups: [Group] = []
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.title = title
        self.groups = groups
    }
    
    public struct Group: Value {
        public var type: FieldType
        public var fields: [Field]
        
        public init(type: FieldType, fields: [Field]) {
            self.type = type
            self.fields = fields
        }
    }
    
    public struct Field: Value {
        public var type: FieldType
        public var specifier: String
        public var value: String
        
        public init(type: FieldType, specifier: String, value: String) {
            self.type = type
            self.specifier = specifier
            self.value = value
        }
    }
    
    public enum FieldType: String, Value, CaseIterable {
        case certificate = "Certificate"
        case phoneNumber = "Phone Number"
        case emailAddress = "Email Address"
        case address = "Address"
        case other = "Other"
        
        public var specifiers: [String]? {
            switch self {
            case .certificate:
                return nil
            case .phoneNumber:
                return ["work", "cell"]
            case .emailAddress:
                return ["work", "personal"]
            case .address:
                return ["work"]
            case .other:
                return nil
            }
        }
    }
    
    
    
    
}

#if DEBUG
extension Card {
    public static let david: Card = Card(
        firstName: "David",
        lastName: "Street",
        title: "Project Manager",
        groups: [
            .init(type: .phoneNumber, fields: [.init(type: .phoneNumber, specifier: "cell", value: "555-555-5555")])
        ]
    )
    
    public static let luke: Card = Card(
        firstName: "Luke",
        lastName: "Street",
        title: "Software Developer",
        groups: [
            .init(type: .phoneNumber, fields: [.init(type: .phoneNumber, specifier: "cell", value: "555-555-5555")])
        ]
    )
}

extension Array where Element == Card {
    public static var all: [Card] {
        [.david, .luke, .david, .luke]
    }
}
#endif
