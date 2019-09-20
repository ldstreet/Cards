//
//  Action.swift
//  BusinessCard
//
//  Created by Luke Street on 9/17/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import Foundation

extension App {
    enum Action {
        
        case cards(CardsAction)
        case create(CreateCardAction)
        case updateCreateCardState(CreateCardState)
        case showCreateCard(Bool)
        case confirmCreateCardCancel(Bool)

        var cards: CardsAction? {
            get {
                guard case let .cards(value) = self else { return nil }
                return value
            }
            set {
                guard case .cards = self, let newValue = newValue else { return }
                self = .cards(newValue)
            }
        }

        var create: CreateCardAction? {
            get {
                guard case let .create(value) = self else { return nil }
                return value
            }
            set {
                guard case .create = self, let newValue = newValue else { return }
                self = .create(newValue)
            }
        }

        var updateCreateCardState: CreateCardState? {
            get {
                guard case let .updateCreateCardState(value) = self else { return nil }
                return value
            }
            set {
                guard case .updateCreateCardState = self, let newValue = newValue else { return }
                self = .updateCreateCardState(newValue)
            }
        }

        var showCreateCard: Bool? {
            get {
                guard case let .showCreateCard(value) = self else { return nil }
                return value
            }
            set {
                guard case .showCreateCard = self, let newValue = newValue else { return }
                self = .showCreateCard(newValue)
            }
        }

        var confirmCreateCardCancel: Bool? {
            get {
                guard case let .confirmCreateCardCancel(value) = self else { return nil }
                return value
            }
            set {
                guard case .confirmCreateCardCancel = self, let newValue = newValue else { return }
                self = .confirmCreateCardCancel(newValue)
            }
        }
    }
}
