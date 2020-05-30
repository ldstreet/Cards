//
//  CreateCardReducer.swift
//  BusinessCard
//
//  Created by Luke Street on 12/17/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import Foundation
import ComposableArchitecture
import Combine
import Models

extension CreateCard {
    static let reducer = Reducer<State, Action, Environment>.combine(
        FieldGroup.reducer.forEach(
            state: \.card.groups,
            action: /Action.groups,
            environment: { _ in .init() }
        ),
        .init { state, action, environment in
            switch action {
            case .nameChanged(let str):
                state.card.name = str
            case .titleChanged(let str):
                state.card.title = str
            case .groups: break
            case .cancel: break
            case .done: break
            case .scanResult(let images):
                let textPublishers = images.map(textRecognition)
                let effect = Publishers.MergeMany(textPublishers)
                    .reduce("", { $0 + "\n" + $1 })
                    .replaceError(with: "")
                    .map { (text: String) -> Card in
                        let fieldDict = detectAddressAndPhoneNumberAndEmail(from: text)
                        let names = detectName(from: text)
                        
                        let groups: [Card.Group] = fieldDict.map { keyValue in
                            let (key, values) = keyValue
                            return Card.Group(
                                type: key,
                                fields: values.map { value in
                                    Card.Field(
                                        type: key,
                                        specifier: "",
                                        value: value
                                    )
                                }
                            )
                        }
                        return Card(
                            name: names.first ?? "",
                            title: "",
                            groups: groups
                        )
                }
                .map { return Action.append($0) }
                .eraseToEffect()
                let hidePublisher = Just(Action.showCameraImport(false)).eraseToEffect()
                return effect.merge(with: hidePublisher).eraseToEffect()
            case .append(let card):
                state.card = state.card.merged(with: card)
                
            case .showCameraImport(let show):
                state.showCameraImport = show
                
            }
            
            return .none
        }
    )
    
}

extension Card {
    func settled() -> Card {
        let dictionary = groups.reduce(into: [Card.FieldType : [Card.Field]]()) { result, element in
            if let values = result[element.type] {
                let filteredValues = values.filter { !$0.value.isEmpty }
                result[element.type]?.append(contentsOf: filteredValues)
            } else {
                result[element.type] = element.fields.filter { !$0.value.isEmpty }
            }
        }
        
        let newGroups = Card
            .FieldType
            .allCases
            .compactMap { type in
                dictionary[type].map { Card.Group(type: type, fields: $0) }
        }
        var newCard = self
        newCard.groups = newGroups
        return newCard
    }
    
    func merged(with card: Card) -> Card {
        var newCard = self
        if newCard.name.isEmpty {
            newCard.name = card.name
        }
        newCard.groups += card.groups
        return newCard.settled()
    }
}
