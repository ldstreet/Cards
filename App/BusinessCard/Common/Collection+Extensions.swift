//
//  Collection+Extensions.swift
//  CardsShare
//
//  Created by Luke Street on 6/25/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import Foundation

extension Collection {
    subscript(safe index: Index) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}
