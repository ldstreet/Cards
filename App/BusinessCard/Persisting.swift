//
//  File.swift
//  
//
//  Created by Luke Street on 4/10/20.
//

import Foundation
import ComposableArchitecture



extension Reducer where State: Codable {
    public func persisting(
        at url: URL
    ) -> Self {
        return .init { value, action, env  in
            let effects = self(&value, action, env)
            let newValue = value
            
            return Effect<Action, Never>.fireAndForget {
                try! JSONEncoder()
                .encode(newValue)
                .write(to: url)
            }.merge(with: effects).eraseToEffect()
        }
    }
}
