//
//  File.swift
//  
//
//  Created by Luke Street on 10/7/19.
//

import Foundation

public struct ShareLink: Codable {
    public var path: String
    
    public init(path: String) {
        self.path = path
    }
}
