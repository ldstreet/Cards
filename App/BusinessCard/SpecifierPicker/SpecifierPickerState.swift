//
//  SpecifierPickerState.swift
//  BusinessCard
//
//  Created by Luke Street on 1/6/20.
//  Copyright © 2020 Luke Street. All rights reserved.
//

import Foundation

extension SpecifierPicker {
    struct State: Equatable {
        var specifiers: [String]
        var selection: Int
        
        var selectedSpecifier: String {
            get {
                guard specifiers.indices.contains(selection) else { return specifiers.first ?? "" }
                return specifiers[selection]
            }
        }
    }
}
