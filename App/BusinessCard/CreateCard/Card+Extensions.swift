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
            groups: FieldType.allCases.map {
                Group(
                    type: $0,
                    fields: []
                )
            }
        )
    }
    
    var hasBeenChanged: Bool {
        return
            !name.isEmpty ||
            !title.isEmpty ||
            !groups.allSatisfy { !$0.hasBeenChanged }
    }
}

extension Card.Group {
    var hasBeenChanged: Bool {
        return !self.fields.allSatisfy { !$0.hasBeenChanged }
    }
}

extension Card.Field {
    var hasBeenChanged: Bool {
        return !value.isEmpty
    }
}

extension Card.FieldType {
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
