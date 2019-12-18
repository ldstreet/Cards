//
//  CreateCardAction.swift
//  BusinessCard
//
//  Created by Luke Street on 12/17/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import Foundation

extension CreateCard {
    enum Action: Equatable {
        case firstNameChanged(String)
        case lastNameChanged(String)
        case titleChanged(String)
        case fieldChanged(value: String, indexPath: IndexPath)
        case fieldSpecifierChanged(specifierIndex: Int, indexPath: IndexPath)
        case cancel
        case done
    }
}
