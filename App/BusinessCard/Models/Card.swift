//
//  Card.swift
//  CardsShare
//
//  Created by Luke Street on 6/14/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import Foundation

typealias Value = Codable & Hashable

struct Card: Value, Identifiable {
    
    let id: UUID
    var firstName: String
    var lastName: String
    var title: String
    var fields: Fields
    
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
    
    struct Fields: Value, ExpressibleByArrayLiteral {
        init(arrayLiteral elements: Card.Fields.Group.Field...) {
            let dictionary = Dictionary(grouping: elements){ $0.type }
            self.groups = Fields.Group.Field.DataType.allCases.compactMap { type in
                guard let fields = dictionary[type] else { return nil }
                return Fields.Group(type: type, fields: fields)
            }.sorted { group1, group2 in
                return group1.type.rawValue > group2.type.rawValue
            }
        }
        
        mutating func append(field: Group.Field) {
            
            if let index = groups.firstIndex(where: { $0.type == field.type }) {
                groups[index].fields.append(field)
            } else {
                groups.append(.init(type: field.type, fields: [field]))
                groups.sort { group1, group2 in
                    return group1.type.rawValue > group2.type.rawValue
                }
            }
        }
        
        var groups: [Group]
        
        struct Group: Value, Identifiable {
            let id = UUID()
            let type: Field.DataType
            var fields: [Field]
            
            struct Field: Value, Identifiable {
                var type: DataType
                var specifier: String
                var value: String
                let id = UUID()
                
                enum DataType: String, Value, CaseIterable {
                    case certificate = "Certificate"
                    case phoneNumber = "Phone Number"
                    case emailAddress = "Email Address"
                    case address = "Address"
                    case other = "Other"
                    
                    var specifiers: [String] {
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
    
    
    static var david: Card {
        Card(
            firstName: "David",
            lastName: "Street",
            title: "ProjectManager",
            fields: [
                Card.Fields.Group.Field(type: .phoneNumber, specifier: "home", value: "555-555-5555")
            ]
        )
    }
    
    static var luke: Card {
        Card(
            firstName: "Luke",
            lastName: "Street",
            title: "Software Developer",
            fields: [
                Card.Fields.Group.Field(type: .phoneNumber, specifier: "cell", value: "555-555-5555")
            ]
        )
    }
    
    
}

extension Array where Element == Card {
    static var all: [Card] {
        [.david, .luke, .david, .luke]
    }
}
#endif
