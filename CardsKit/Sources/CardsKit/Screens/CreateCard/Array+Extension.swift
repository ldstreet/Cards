//
//  Array+Extension.swift
//  CardsKit
//
//  Created by Luke Street on 4/2/19.
//

import Foundation

extension Array {
    subscript(safe index: Int) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}
