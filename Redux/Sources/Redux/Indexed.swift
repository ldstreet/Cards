//
//  File.swift
//  
//
//  Created by Luke Street on 4/7/20.
//

import Foundation

public struct Indexed<Value: Equatable>: Equatable {
    public var index: Int
    public var value: Value

    public init(index: Int, value: Value) {
        self.index = index
        self.value = value
    }
}

public func indexed<State, Action, GlobalState, GlobalAction>(
  reducer: @escaping Reducer<State, Action>,
  _ stateKeyPath: WritableKeyPath<GlobalState, [State]>,
  _ actionKeyPath: WritableKeyPath<GlobalAction, Indexed<Action>?>
) -> Reducer<GlobalState, GlobalAction> {
    return { globalValue, globalAction in
        guard let localIndexedAction = globalAction[keyPath: actionKeyPath] else { return [] }
        let index = localIndexedAction.index
        let localEffects = reducer(&globalValue[keyPath: stateKeyPath][index], localIndexedAction.value)
        return localEffects.map { localEffect in
            localEffect.map { action in
                var globalAction = globalAction
                globalAction[keyPath: actionKeyPath] = Indexed(index: index, value: action)
                return globalAction
            }.eraseToEffect()
        }
    }
}
