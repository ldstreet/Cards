//
//  World.swift
//  CardsKit
//
//  Created by Luke Street on 2/14/19.
//

#if os(iOS)
import Foundation
import LDSiOSKit

internal struct World {
    let environment: Environment = {
        guard
            let environmentString = Bundle.main.object(forInfoDictionaryKey: "environment") as? String,
            let environment = Environment(rawValue: environmentString)
        else { return Environment.develop }
        
        return environment
    }()
    
    let date: () -> Date = Date.init
}

let Current = World()
#endif
