//
//  Cards.Action.swift
//  BusinessCard
//
//  Created by Luke Street on 9/1/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import Foundation

extension Cards {
    enum Action {
        case delete(UUID)
        case proposeCardDelete(UUID?)
        case share(UUID)
        case presentShareLink(URL?)
        case showDetail(UUID?)
        case detail(CardDetail.Action)

        var delete: UUID? {
            get {
                guard case let .delete(value) = self else { return nil }
                return value
            }
            set {
                guard case .delete = self, let newValue = newValue else { return }
                self = .delete(newValue)
            }
        }

        var proposeCardDelete: UUID?? {
            get {
                guard case let .proposeCardDelete(value) = self else { return nil }
                return value
            }
            set {
                guard case .proposeCardDelete = self, let newValue = newValue else { return }
                self = .proposeCardDelete(newValue)
            }
        }

        var share: UUID? {
            get {
                guard case let .share(value) = self else { return nil }
                return value
            }
            set {
                guard case .share = self, let newValue = newValue else { return }
                self = .share(newValue)
            }
        }

        var presentShareLink: URL?? {
            get {
                guard case let .presentShareLink(value) = self else { return nil }
                return value
            }
            set {
                guard case .presentShareLink = self, let newValue = newValue else { return }
                self = .presentShareLink(newValue)
            }
        }

        var showDetail: UUID?? {
            get {
                guard case let .showDetail(value) = self else { return nil }
                return value
            }
            set {
                guard case .showDetail = self, let newValue = newValue else { return }
                self = .showDetail(newValue)
            }
        }

        var detail: CardDetail.Action? {
            get {
                guard case let .detail(value) = self else { return nil }
                return value
            }
            set {
                guard case .detail = self, let newValue = newValue else { return }
                self = .detail(newValue)
            }
        }
    }
}

