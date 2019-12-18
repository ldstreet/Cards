//
//  Carrd+Extensions.swift
//  BusinessCard
//
//  Created by Luke Street on 12/17/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import Foundation
import Models
import SwiftUI

extension Card {
    static func createDefaultCard() -> Card {
        .init(
            fields: [
                .init(type: .phoneNumber, specifier: "cell", value: ""),
                .init(type: .phoneNumber, specifier: "work", value: ""),
                .init(type: .emailAddress, specifier: "work", value: ""),
                .init(type: .address, specifier: "work", value: "")
            ]
        )
    }
    
    var hasBeenChanged: Bool {
        return
            !firstName.isEmpty ||
            !lastName.isEmpty ||
            !title.isEmpty ||
            fields.hasBeenChanged
    }
}

extension Card.Fields {
    var hasBeenChanged: Bool {
        return groups.reduce(false, { return $0 || $1.hasBeenChanged })
    }
}

extension Card.Fields.Group {
    var hasBeenChanged: Bool {
        return fields.reduce(false, { return $0 || $1.hasBeenChanged })
    }
}

extension Card.Fields.Group.Field {
    var hasBeenChanged: Bool {
        return false
    }
}

extension Card.Fields.Group.Field {
    var specifierIndex: Int {
        get { type.specifiers.firstIndex(where: { $0 == self.specifier })! }
        set { specifier = type.specifiers[newValue] }
    }
}

extension Card.Fields.Group.Field.DataType {
    public var contentType: UITextContentType? {
        switch self {
        case .certificate: return nil
        case .phoneNumber: return .telephoneNumber
        case .emailAddress: return .emailAddress
        case .address: return .fullStreetAddress
        case .other: return nil
        }
    }
    
    public var keyboardType: UIKeyboardType {
        switch self {
        case .certificate: return .default
        case .phoneNumber: return .phonePad
        case .emailAddress: return .emailAddress
        case .address: return .default
        case .other: return .default
        }
    }
}
