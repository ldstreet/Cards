//
//  CreateCardAction.swift
//  BusinessCard
//
//  Created by Luke Street on 12/17/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import Foundation
import Redux

extension CreateCard {
    enum Action: Equatable {
        case firstNameChanged(String)
        case lastNameChanged(String)
        case titleChanged(String)
        case groups(Indexed<FieldGroup.Action>)
        case cancel
        case done

        var firstNameChanged: String? {
            get {
                guard case let .firstNameChanged(value) = self else { return nil }
                return value
            }
            set {
                guard case .firstNameChanged = self, let newValue = newValue else { return }
                self = .firstNameChanged(newValue)
            }
        }

        var lastNameChanged: String? {
            get {
                guard case let .lastNameChanged(value) = self else { return nil }
                return value
            }
            set {
                guard case .lastNameChanged = self, let newValue = newValue else { return }
                self = .lastNameChanged(newValue)
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
