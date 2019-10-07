//
//  File.swift
//  
//
//  Created by Luke Street on 8/18/19.
//

import SwiftUI
import Combine

public typealias Reducer<Value, Action> = (inout Value, Action) -> Void
public typealias AsyncReducer<Value, Action> = ( @escaping () -> Value, Action) -> AnyPublisher<Value, Never>

public func combine<Value, Action>(
    _ reducers: (inout Value, Action) -> Void...
) -> (inout Value, Action) -> Void {
    return { value, action in
        for reducer in reducers {
            reducer(&value, action)
        }
    }
}

public final class Store<Value, Action>: ObservableObject {
    public let reducer: Reducer<Value, Action>
    public let asyncReducer: AsyncReducer<Value, Action>
    @Published public private(set) var value: Value
    private var cancellable: Cancellable?
    private var asyncCancellable: AnyCancellable?

    public init(
        initialValue: Value,
        reducer: @escaping Reducer<Value, Action>,
        asyncReducer: @escaping AsyncReducer<Value, Action>
    ) {
        self.reducer = reducer
        self.asyncReducer = asyncReducer
        self.value = initialValue
    }

    public func send(_ action: Action) {
        self.reducer(&self.value, action)
    }
    
    public func dumbSend<LocalValue>(
        binding: WritableKeyPath<Value, LocalValue>
    ) -> Binding<LocalValue> {
        return Binding<LocalValue>(
            get: { return self.value[keyPath: binding] },
            set: { [self] newVal in
                self.value[keyPath: binding] = newVal
            }
        )
        
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
    
    public func asyncSend(_ action: Action) {
        asyncCancellable = self.asyncReducer(
            { return self.value },
            action
        )
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
            .assign(to: \Store<Value, Action>.value, on: self)
    }
    
    public func view<LocalValue, LocalAction>(
        value toLocalValue: KeyPath<Value, LocalValue>,
        action toGlobalAction: @escaping (LocalAction) -> Action
    ) -> Store<LocalValue, LocalAction> {
        let localStore = Store<LocalValue, LocalAction>(
            initialValue: self.value[keyPath: toLocalValue],
            reducer: { localValue, localAction in
                self.send(toGlobalAction(localAction))
                localValue = self.value[keyPath: toLocalValue]
            },
            asyncReducer: { getter, action in
                return self
                    .asyncReducer({ return self.value }, toGlobalAction(action))
                    .map { val in
                        let localVal = val[keyPath: toLocalValue]
                        return localVal
                    }
                    .eraseToAnyPublisher()
            }
        )
        localStore.cancellable = self.$value.sink { [weak localStore] newValue in
            localStore?.value = newValue[keyPath: toLocalValue]
        }
        return localStore
    }
}

public func pullback<LocalValue, GlobalValue, LocalAction, GlobalAction>(
    _ reducer: @escaping AsyncReducer<LocalValue, LocalAction>,
    value: WritableKeyPath<GlobalValue, LocalValue>,
    action: WritableKeyPath<GlobalAction, LocalAction?>
) -> AsyncReducer<GlobalValue, GlobalAction> {
    return { getter, globalAction in
        guard let unwrappedAction = globalAction[keyPath: action] else {
            return Just(getter()).eraseToAnyPublisher()
        }
        
        return reducer(
            {
                return getter()[keyPath: value]
            },
            unwrappedAction
        ).map { localValue in
            var globalValue = getter()
            globalValue[keyPath: value] = localValue
            return globalValue
        }.eraseToAnyPublisher()
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
