//
//  CreateCardAction.swift
//  BusinessCard
//
//  Created by Luke Street on 12/17/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import Foundation
import ComposableArchitecture
import VisionKit
import Models

extension CreateCard {
    enum Action: Equatable {
        case nameChanged(String)
        case titleChanged(String)
        case groups(Int, FieldGroup.Action)
        case scanResult([UIImage])
        case cancel
        case done
        case append(Card)
        case showCameraImport(Bool)
    }
}
