//
//  Card.swift
//  CardsShare
//
//  Created by Luke Street on 6/14/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import Foundation

public typealias Value = Codable & Hashable

public struct Card: Value, Identifiable, Equatable {
    
    public var id: UUID
    public var firstName: String
    public var lastName: String
    public var title: String
    public var fields: Fields
    
    public init(
        id: UUID = .init(),
        firstName: String = "",
        lastName: String = "",
        title: String = "",
        fields: Fields = []
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.title = title
        self.fields = fields
    }
    
    public struct Fields: Value, ExpressibleByArrayLiteral {
        public init(arrayLiteral elements: Card.Fields.Group.Field...) {
            let dictionary = Dictionary(grouping: elements){ $0.type }
            self.groups = Fields.Group.Field.DataType.allCases.compactMap { type in
                guard let fields = dictionary[type] else { return nil }
                return Fields.Group(type: type, fields: fields)
            }.sorted { group1, group2 in
                return group1.type.rawValue > group2.type.rawValue
            }
        }
        
        public mutating func append(field: Group.Field) {
            
            if let index = groups.firstIndex(where: { $0.type == field.type }) {
                groups[index].fields.append(field)
            } else {
                groups.append(.init(type: field.type, fields: [field]))
                groups.sort { group1, group2 in
                    return group1.type.rawValue > group2.type.rawValue
                }
            }
        }
        
        public var groups: [Group]
        
        public struct Group: Value, Identifiable {
            public let id = UUID()
            public let type: Field.DataType
            public var fields: [Field]
            
            public init(
                type: Field.DataType,
                fields: [Field]
            ) {
                self.type = type
                self.fields = fields
            }
            
            public struct Field: Value, Identifiable {
                public var type: DataType
                public var specifier: String
                public var value: String
                public let id = UUID()
                
                public init(
                    type: Field.DataType,
                    specifier: String,
                    value: String
                ) {
                    self.type = type
                    self.specifier = specifier
                    self.value = value
                }
                
                public enum DataType: String, Value, CaseIterable {
                    case certificate = "Certificate"
                    case phoneNumber = "Phone Number"
                    case emailAddress = "Email Address"
                    case address = "Address"
                    case other = "Other"
                    
                    public var specifiers: [String] {
                        switch self {
                        case .certificate:
                            return []
                        case .phoneNumber:
                            return ["work", "cell"]
                        case .emailAddress:
                            return ["work", "personal",]
                        case .address:
                            return ["work"]
                        case .other:
                            return []
                        }
                    }
                }
            }
        }
    }
}

#if DEBUG
extension Card {
    
    
    public static let david: Card = Card(
        firstName: "David",
        lastName: "Street",
        title: "ProjectManager",
        fields: [
            Card.Fields.Group.Field(type: .phoneNumber, specifier: "home", value: "555-555-5555")
        ]
    )
    
    public static let luke: Card = Card(
        firstName: "Luke",
        lastName: "Street",
        title: "Software Developer",
        fields: [
            Card.Fields.Group.Field(type: .phoneNumber, specifier: "cell", value: "555-555-5555")
        ]
    )
    
    
}

extension Array where Element == Card {
    public static var all: [Card] {
        [.david, .luke, .david, .luke]
    }
}
#endif
