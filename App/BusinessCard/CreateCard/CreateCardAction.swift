//
//  CreateCardAction.swift
//  BusinessCard
//
//  Created by Luke Street on 12/17/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import Foundation
import Redux
import VisionKit
import Models

extension CreateCard {
    enum Action: Equatable {
        case nameChanged(String)
        case titleChanged(String)
        case groups(Indexed<FieldGroup.Action>)
        case scanResult([UIImage])
        case cancel
        case done
        case append(Card)
        case showCameraImport(Bool)

        var nameChanged: String? {
            get {
                guard case let .nameChanged(value) = self else { return nil }
                return value
            }
            set {
                guard case .nameChanged = self, let newValue = newValue else { return }
                self = .nameChanged(newValue)
            }
        }

        var titleChanged: String? {
            get {
                guard case let .titleChanged(value) = self else { return nil }
                return value
            }
            set {
                guard case .titleChanged = self, let newValue = newValue else { return }
                self = .titleChanged(newValue)
            }
        }

        var groups: Indexed<FieldGroup.Action>? {
            get {
                guard case let .groups(value) = self else { return nil }
                return value
            }
            set {
                guard case .groups = self, let newValue = newValue else { return }
                self = .groups(newValue)
            }
        }

        var cancel: Void? {
            guard case .cancel = self else { return nil }
            return ()
        }

        var done: Void? {
            guard case .done = self else { return nil }
            return ()
        }
    }
}
