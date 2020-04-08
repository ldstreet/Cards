//
//  World.swift
//  BusinessCard
//
//  Created by Luke Street on 9/30/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import Foundation

public struct World {
    var environment: NetworkEnvironment = {
        guard
            let environmentString = Bundle.main.object(forInfoDictionaryKey: "environment") as? String,
            let environment = NetworkEnvironment(rawValue: environmentString)
        else { return NetworkEnvironment.develop }
        
        return environment
    }()
    
    var date: () -> Date = Date.init
}

#if DEBIG
public var Current = World()
#else
public let Current = World()
#endif
