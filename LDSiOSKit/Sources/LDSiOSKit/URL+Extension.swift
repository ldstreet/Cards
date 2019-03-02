//
//  URL+Extension.swift
//  LDSiOSKit
//
//  Created by Luke Street on 2/16/19.
//

import Foundation

extension URL {
    public init(static string: StaticString) {
        guard let url = URL(string: "\(string)") else {
            fatalError("Not a valid url: \(string)")
        }
        self = url
    }
}
