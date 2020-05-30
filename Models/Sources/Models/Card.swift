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
    public var name: String
    public var title: String
    public var groups: [Group]
    
    public init(
        id: UUID = .init(),
        name: String = "",
        title: String = "",
        groups: [Group] = []
    ) {
        self.id = id
        self.name = name
        self.title = title
        self.groups = groups
    }
    
    public struct Group: Value, Identifiable {
        public var type: FieldType
        public var fields: [Field]
        public let id: UUID
        
        public init(type: FieldType, fields: [Field], id: UUID = .init()) {
            self.type = type
            self.fields = fields
            self.id = id
        }
    }
    
    public struct Field: Value, Identifiable {
        public var type: FieldType
        public var specifier: String
        public var value: String
        public var id: UUID
        
        public init(type: FieldType, specifier: String, value: String, id: UUID = .init()) {
            self.type = type
            self.specifier = specifier
            self.value = value
            self.id = id
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
        name: "David Street",
        title: "Project Manager",
        groups: [
            .init(type: .phoneNumber, fields: [.init(type: .phoneNumber, specifier: "cell", value: "555-555-5555")], id: .init())
        ]
    )
    
    public static let luke: Card = Card(
        name: "Luke Street",
        title: "Software Developer",
        groups: [
            .init(type: .phoneNumber, fields: [.init(type: .phoneNumber, specifier: "cell", value: "555-555-5555")], id: .init())
        ]
    )
}

extension Array where Element == Card {
    public static var all: [Card] {
        [.david, .luke, .david, .luke]
    }
}
#endif
