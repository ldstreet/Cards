//
//  CardsController.swift
//  App
//
//  Created by Luke Street on 2/13/19.
//

import Foundation
import CardsKit

struct Pass: Codable {
	let passTypeIdentifier: String
	let formatVersion: Int
	let organizationName: String
	let serialNumber: String
	let teamIdentifier: String
	let generic: Generic
	let backgroundColor: String
	let foregroundColor: String
	let labelColor: String
	let associatedStoreIdentifiers: [Int]
	let description: String
	let logoText: String
	let voided: Bool
}

extension Pass {
    init(from card: Card) {
        self.passTypeIdentifier = "pass.com.ldstreet.cards"
        self.formatVersion = 1
        self.organizationName = "Street Brothers"
        self.serialNumber = card.uuid.uuidString
        self.teamIdentifier = "9C9LVX9RE8"
        self.generic = .init(
            headerFields: [
              .init(key: "h1", value: "\(card.firstName) \(card.lastName)", label: "name")
            ],
            secondaryFields: [
                .init(key: "s1", value: card.phoneNumber, label: "Phone Number", textAlignment: "PKTextAlignmentLeft"),
                .init(key: "s2", value: card.emailAddress, label: "Email Address", textAlignment: "PKTextAlignmentLeft")
                
            ],
            backFields: [
                .init(key: "b1", value: card.phoneNumber, label: "Phone Number"),
                .init(key: "b2", value: card.emailAddress, label: "Email Address")
            ]
        )
        self.backgroundColor = "rgb(212,203,205)"
        self.foregroundColor = "rgb(35,41,66)"
        self.labelColor = "rgb(13,84,28)"
        self.associatedStoreIdentifiers = [
            1278792998
        ]
        self.description = "Business Card"
        self.logoText = "\(card.firstName) \(card.lastName)"
        self.voided = true
    }
}
