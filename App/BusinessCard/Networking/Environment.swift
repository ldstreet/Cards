//
//  Environment.swift
//  CardsKit
//
//  Created by Luke Street on 2/13/19.
//

#if os(iOS)
import Foundation


public enum NetworkEnvironment: String, EnvironmentProvider {
    case local
    case develop
    case production
    
    public var url: URL {
        switch self {
            
        case .local:
            return URL(static: "http://localhost:8080")
        case .develop:
            return URL(static: "https://cards-develop.v2.vapor.cloud")
        case .production:
            return URL(static: "https://cards.v2.vapor.cloud")
        }
    }
}
#endif

