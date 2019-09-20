//
//  File.swift
//  
//
//  Created by Luke Street on 8/18/19.
//

import Foundation

public typealias Reducer<Value, Action> = (inout Value, Action) -> Void

public func combine<Value, Action>(
    _ reducers: (inout Value, Action) -> Void...
) -> (inout Value, Action) -> Void {
    return { value, action in
        for reducer in reducers {
            reducer(&value, action)
        }
    }
}

public typealias GlobalFromLocaling<Global, Local> = (Local) -> Global?

public func pullforward<LocalValue, GlobalValue, LocalAction, GlobalAction>(
    _ store: Store<GlobalValue, GlobalAction>,
    value: WritableKeyPath<GlobalValue, LocalValue>,
    globalActionFromLocal: @escaping GlobalFromLocaling<GlobalAction, LocalAction>
) -> Store<LocalValue, LocalAction> {
    return Store<LocalValue, LocalAction>(
        initialValue: store.value[keyPath: value],
        reducer: pullforward(
            globalStore: store,
            valueKeyPath: value,
            globalActionFromLocal: globalActionFromLocal
        )
    )
}

public func pullforward<LocalValue, GlobalValue, LocalAction, GlobalAction>(
    _ store: Store<GlobalValue, GlobalAction>,
    localValue: LocalValue,
    value: WritableKeyPath<GlobalValue, LocalValue?>,
    globalActionFromLocal: @escaping GlobalFromLocaling<GlobalAction, LocalAction>
) -> Store<LocalValue, LocalAction> {
    return Store<LocalValue, LocalAction>(
        initialValue: localValue,
        reducer: pullforward(
            globalStore: store,
            valueKeyPath: value,
            globalActionFromLocal: globalActionFromLocal
        )
    )
}
import SwiftUI
public final class Store<Value, Action>: ObservableObject {
    public let reducer: Reducer<Value, Action>
    @Published public private(set) var value: Value

    public init(initialValue: Value, reducer: @escaping (inout Value, Action) -> Void) {
        self.reducer = reducer
        self.value = initialValue
    }

    public func send(_ action: Action) {
        self.reducer(&self.value, action)
    }
    
    public func send<LocalValue>(
        _ action: @escaping (LocalValue) -> Action,
        binding: KeyPath<Value, LocalValue>
    ) -> Binding<LocalValue> {
        return Binding<LocalValue>(
            get: { return self.value[keyPath: binding] },
            set: { self.send(action($0)) }
        )
        
    }
    
    public func send<LocalValue, Suppl>(
        _ action: @escaping (LocalValue, Suppl) -> Action,
        binding: @escaping (Value, Suppl) -> (LocalValue),
        suppl: Suppl
    ) -> Binding<LocalValue> {
        return Binding<LocalValue>(
            get: { return binding(self.value, suppl) },
            set: { self.send(action($0, suppl)) }
        )
    }
}

public func pullback<LocalValue, GlobalValue, LocalAction, GlobalAction>(
    _ reducer: @escaping Reducer<LocalValue, LocalAction>,
    value: WritableKeyPath<GlobalValue, LocalValue>,
    action: WritableKeyPath<GlobalAction, LocalAction?>
) ->  Reducer<GlobalValue, GlobalAction> {
    return { globalValue, globalAction in
        guard let unwrappedAction = globalAction[keyPath: action] else { return }
        reducer(&globalValue[keyPath: value], unwrappedAction)
    }
}

public func pullforward<LocalValue, GlobalValue, LocalAction, GlobalAction>(
    globalStore: Store<GlobalValue, GlobalAction>,
    valueKeyPath: WritableKeyPath<GlobalValue, LocalValue>,
    globalActionFromLocal: @escaping GlobalFromLocaling<GlobalAction, LocalAction>
) ->  Reducer<LocalValue, LocalAction> {
    return { [globalStore, globalActionFromLocal] localValue, localAction in
        guard let globalAction = globalActionFromLocal(localAction) else { return }
        globalStore.send(globalAction)
        localValue = globalStore.value[keyPath: valueKeyPath]
    }
}

public func pullforward<LocalValue, GlobalValue, LocalAction, GlobalAction>(
    globalStore: Store<GlobalValue, GlobalAction>,
    valueKeyPath: WritableKeyPath<GlobalValue, LocalValue?>,
    globalActionFromLocal: @escaping GlobalFromLocaling<GlobalAction, LocalAction>
) ->  Reducer<LocalValue, LocalAction> {
    return { [globalStore, globalActionFromLocal] localValue, localAction in
        guard let globalAction = globalActionFromLocal(localAction) else { return }
        globalStore.send(globalAction)
        if let newValue = globalStore.value[keyPath: valueKeyPath] {
            localValue = newValue
        }
    }
}

public func pullback<LocalValue, GlobalValue, LocalAction, GlobalAction>(
    _ reducer: @escaping Reducer<LocalValue, LocalAction>,
    value: WritableKeyPath<GlobalValue, LocalValue?>,
    action: WritableKeyPath<GlobalAction, LocalAction?>
) -> Reducer<GlobalValue, GlobalAction> {
    return { globalValue, globalAction in
        guard let unwrappedAction = globalAction[keyPath: action] else { return }
        guard var unwrappedValue = globalValue[keyPath: value] else { return }
        reducer(&unwrappedValue, unwrappedAction)
        globalValue[keyPath: value] = unwrappedValue
    }
}

public func compose<A, B, C>(
  _ f: @escaping (B) -> C,
  _ g: @escaping (A) -> B
  )
  -> (A) -> C {

    return { (a: A) -> C in
      f(g(a))
    }
}

public func with<A, B>(_ a: A, _ f: (A) throws -> B) rethrows -> B {
  return try f(a)
}

public func logging<Value, Action>(
    _ reducer: @escaping Reducer<Value, Action>
) ->  Reducer<Value, Action> {
    return { value, action in
        reducer(&value, action)
        print("action: \(action)")
        print(dump(value))
    }
}

public func persisting<Value: Codable, Action>(
    _ reducer: @escaping Reducer<Value, Action>,
    at url: URL
) ->  Reducer<Value, Action> {
    return { value, action in
        reducer(&value, action)
        try! JSONEncoder()
            .encode(value)
            .write(to: url)
    }
}
