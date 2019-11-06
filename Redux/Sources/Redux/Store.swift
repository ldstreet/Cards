//
//  File.swift
//  
//
//  Created by Luke Street on 8/18/19.
//

import SwiftUI
import Combine

public typealias Effect<Value, Action> = () -> AnyPublisher<Action, Never>
public typealias Reducer<Value, Action> = (inout Value, Action) -> Effect<Value, Action>

public func combine<Value, Action>(
    _ reducers: Reducer<Value, Action>...
) -> Reducer<Value, Action> {
    return { value, action in
        let effectPublisher = reducers.reduce(AnyPublisher<Action, Never>.empty()) { currentPublisher, reducer in
            reducer(&value, action)().merge(with: currentPublisher).eraseToAnyPublisher()
        }
        return { effectPublisher }
    }
}

extension AnyPublisher {
    public static func empty() -> Self {
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    }
}

public final class Store<Value, Action>: ObservableObject {
    public let reducer: Reducer<Value, Action>
    @Published public private(set) var value: Value
    private var cancellable: Cancellable?
    private var asyncCancellables = Set<AnyCancellable>()

    public init(
        initialValue: Value,
        reducer: @escaping Reducer<Value, Action>
    ) {
        self.reducer = reducer
        self.value = initialValue
    }

    public func send(_ action: Action) {
        let effectPublisher = self.reducer(&self.value, action)
        let newCancellable = effectPublisher()
            .receive(on: RunLoop.main)
            .sink { self.send($0) }
        asyncCancellables.insert(newCancellable)
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
    
    public func view<LocalValue, LocalAction>(
        value toLocalValue: @escaping (Value) -> LocalValue,
        action toGlobalAction: @escaping (LocalAction) -> Action
    ) -> Store<LocalValue, LocalAction> {
        let localStore = Store<LocalValue, LocalAction>(
            initialValue: toLocalValue(value),
            reducer: { localValue, localAction in
                self.send(toGlobalAction(localAction))
                localValue = toLocalValue(self.value)
                return { .empty() }
            }
        )
        localStore.cancellable = self.$value.sink { [weak localStore] newValue in
            localStore?.value = toLocalValue(newValue)
        }
        return localStore
    }
    
    public func view<LocalValue, LocalAction>(
        value toLocalValue: @escaping (Value) -> LocalValue?,
        action toGlobalAction: @escaping (LocalAction) -> Action
    ) -> Store<LocalValue, LocalAction>? {
        guard let localValue = toLocalValue(value) else { return nil }
        let localStore = Store<LocalValue, LocalAction>(
            initialValue: localValue,
            reducer: { localValue, localAction in
                self.send(toGlobalAction(localAction))
                if let newLocalValue = toLocalValue(self.value) {
                    localValue = newLocalValue
                }
                return { .empty() }
            }
        )
        localStore.cancellable = self.$value.sink { [weak localStore] newValue in
            if let newLocalValue = toLocalValue(newValue) {
                localStore?.value =  newLocalValue
            }
        }
        return localStore
    }
}

public func pullback<LocalValue, GlobalValue, LocalAction, GlobalAction>(
    _ reducer: @escaping Reducer<LocalValue, LocalAction>,
    value: WritableKeyPath<GlobalValue, LocalValue>,
    action: WritableKeyPath<GlobalAction, LocalAction?>
) ->  Reducer<GlobalValue, GlobalAction> {
    return { globalValue, globalAction in
        guard let unwrappedAction = globalAction[keyPath: action] else { return { .empty() } }
        let localEffectPublisher = reducer(&globalValue[keyPath: value], unwrappedAction)
        return {
            return localEffectPublisher().map { localAction in
                var globalAction = globalAction
                globalAction[keyPath: action] = localAction
                return globalAction
            }.eraseToAnyPublisher()
        }
    }
}

public func pullback<LocalValue, GlobalValue, LocalAction, GlobalAction>(
    _ reducer: @escaping Reducer<LocalValue, LocalAction>,
    value: WritableKeyPath<GlobalValue, LocalValue?>,
    action: WritableKeyPath<GlobalAction, LocalAction?>
) -> Reducer<GlobalValue, GlobalAction> {
    return { globalValue, globalAction in
        guard let unwrappedAction = globalAction[keyPath: action] else { return { .empty() } }
        guard var unwrappedValue = globalValue[keyPath: value] else { return { .empty() } }
        let localEffectPublisher = reducer(&unwrappedValue, unwrappedAction)
        return {
            return localEffectPublisher().map { localAction in
                var globalAction = globalAction
                globalAction[keyPath: action] = localAction
                return globalAction
            }.eraseToAnyPublisher()
        }
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
        let effectPublisher = reducer(&value, action)
        let newValue = value
        return {
            print("action: \(action)")
            print(dump(newValue))
            return effectPublisher()
        }
    }
}

public func persisting<Value: Codable, Action>(
    _ reducer: @escaping Reducer<Value, Action>,
    at url: URL
) ->  Reducer<Value, Action> {
    return { value, action in
        let effectPublisher = reducer(&value, action)
        let newValue = value
        return {
            try! JSONEncoder()
                .encode(newValue)
                .write(to: url)
            return effectPublisher()
        }
    }
}
