//
//  Environment.swift
//  CardsKit
//
//  Created by Luke Street on 2/13/19.
//

#if os(iOS)
import Foundation
import LDSiOSKit


public enum Environment: String, EnvironmentProvider {
    case local
    case develop
    case production
    
    public var url: URL {
        switch self {
            
        case .local:
            return URL(static: "http://localhost:8080")
        case .develop:
            return URL(static: "https://card-develop.vapor.cloud")
        case .production:
            return URL(static: "https://card.vapor.cloud")
        }
    }
}
#endif

