//
//  File.swift
//  
//
//  Created by Luke Street on 8/18/19.
//

import SwiftUI
import Combine

public struct Effect<Output>: Publisher {
    public typealias Failure = Never
    
    let publisher: AnyPublisher<Output, Failure>
    
    public func receive<S>(
        subscriber: S
    ) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        self.publisher.receive(subscriber: subscriber)
    }
}

extension Publisher where Failure == Never {
    public func eraseToEffect() -> Effect<Output> {
        return Effect(publisher: self.eraseToAnyPublisher())
    }
}
public typealias Reducer<Value, Action> = (inout Value, Action) -> [Effect<Action>]

public func combine<Value, Action>(
    _ reducers: Reducer<Value, Action>...
) -> Reducer<Value, Action> {
    return { value, action in
        let effects = reducers.flatMap { $0(&value, action) }
        return effects
    }
}

extension AnyPublisher {
    public static func empty() -> Self {
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    }
}

public final class Store<Value, Action>: ObservableObject {
    private let reducer: Reducer<Value, Action>
    @Published public private(set) var value: Value {
        didSet {
            print("changed")
        }
    }
    private var viewCancellable: Cancellable?
    private var effectCancellables: Set<AnyCancellable> = []
    
    public init(initialValue: Value, reducer: @escaping Reducer<Value, Action>) {
        self.reducer = reducer
        self.value = initialValue
    }
    
    public func send(_ action: Action) {
        let effects = self.reducer(&self.value, action)
        effects.forEach { effect in
            var effectCancellable: AnyCancellable?
            var didComplete = false
            effectCancellable = effect.sink(
                receiveCompletion: { [weak self] _ in
                    didComplete = true
                    guard let effectCancellable = effectCancellable else { return }
                    self?.effectCancellables.remove(effectCancellable)
                },
                receiveValue: self.send
            )
            if !didComplete, let effectCancellable = effectCancellable {
                self.effectCancellables.insert(effectCancellable)
            }
        }
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
            initialValue: toLocalValue(self.value),
            reducer: { localValue, localAction in
                self.send(toGlobalAction(localAction))
                localValue = toLocalValue(self.value)
                return []
            }
        )
        localStore.viewCancellable = self.$value.receive(on: RunLoop.main).sink { [weak localStore] newValue in
            localStore?.value = toLocalValue(newValue)
        }
        return localStore
    }
    
//    public func view<LocalValue, LocalAction>(
//        value toLocalValue: @escaping (Value) -> LocalValue?,
//        fallback: LocalValue,
//        action toGlobalAction: @escaping (LocalAction) -> Action
//    ) -> Store<LocalValue, LocalAction> {
//        let localStore = Store<LocalValue, LocalAction>(
//            initialValue: toLocalValue(self.value) ?? fallback,
//            reducer: { localValue, localAction in
//                self.send(toGlobalAction(localAction))
//                if let newLocalValue = toLocalValue(self.value) {
//                    localValue = newLocalValue
//                }
//                return []
//        }
//        )
//        localStore.viewCancellable = self.$value.sink { [weak localStore] newValue in
//            if let newLocalValue = toLocalValue(newValue) {
//                localStore?.value =  newLocalValue
//            }
//        }
//        return localStore
//    }
    
    public func view<LocalValue, LocalAction>(
        value toLocalValue: @escaping (Value) -> LocalValue?,
        action toGlobalAction: @escaping (LocalAction) -> Action
    ) -> Store<LocalValue, LocalAction>? {
        
        guard let localValue = toLocalValue(self.value) else { return nil }
        let localStore = Store<LocalValue, LocalAction>(
            initialValue: localValue,
            reducer: { localValue, localAction in
                self.send(toGlobalAction(localAction))
                if let newLocalValue = toLocalValue(self.value) {
                    localValue = newLocalValue
                }
                return []
            }
        )
        localStore.viewCancellable = self.$value.sink { [weak localStore] newValue in
            if let newLocalValue = toLocalValue(newValue) {
                localStore?.value =  newLocalValue
            }
        }
        return localStore
    }
    
//    public func view<LocalValue, LocalAction>(
//        value toLocalValue: @escaping (Value) -> LocalValue?,
//        action toGlobalAction: @escaping (LocalAction) -> Action
//    ) -> Store<LocalValue, LocalAction>? {
//        guard let localValue = toLocalValue(value) else { return nil }
//        let localStore = Store<LocalValue, LocalAction>(
//            initialValue: localValue,
//            reducer: { localValue, localAction in
//                self.send(toGlobalAction(localAction))
//                if let newLocalValue = toLocalValue(self.value) {
//                    localValue = newLocalValue
//                }
//                return { .empty() }
//        }
//        )
//        localStore.cancellable = self.$value.sink { [weak localStore] newValue in
//            if let newLocalValue = toLocalValue(newValue) {
//                localStore?.value =  newLocalValue
//            }
//        }
//        return localStore
//    }
}

//public final class Store<Value, Action>: ObservableObject {
//    public let reducer: Reducer<Value, Action>
//    @Published public private(set) var value: Value
//    private var cancellable: Cancellable?
//    private var asyncCancellables = Set<AnyCancellable>()
//
//    public init(
//        initialValue: Value,
//        reducer: @escaping Reducer<Value, Action>
//    ) {
//        self.reducer = reducer
//        self.value = initialValue
//    }
//
//    public func send(_ action: Action) {
//        let effectPublisher = self.reducer(&self.value, action)
//        let newCancellable = effectPublisher()
//            .receive(on: RunLoop.main)
//            .sink { self.send($0) }
//        asyncCancellables.insert(newCancellable)
//    }
//    
//    public func send<LocalValue>(
//        _ action: @escaping (LocalValue) -> Action,
//        binding: KeyPath<Value, LocalValue>
//    ) -> Binding<LocalValue> {
//        return Binding<LocalValue>(
//            get: { return self.value[keyPath: binding] },
//            set: { self.send(action($0)) }
//        )
//        
//    }
//    
//    public func send<LocalValue, Suppl>(
//        _ action: @escaping (LocalValue, Suppl) -> Action,
//        binding: @escaping (Value, Suppl) -> (LocalValue),
//        suppl: Suppl
//    ) -> Binding<LocalValue> {
//        return Binding<LocalValue>(
//            get: { return binding(self.value, suppl) },
//            set: { self.send(action($0, suppl)) }
//        )
//    }
//    
//    public func view<LocalValue, LocalAction>(
//        value toLocalValue: @escaping (Value) -> LocalValue,
//        action toGlobalAction: @escaping (LocalAction) -> Action
//    ) -> Store<LocalValue, LocalAction> {
//        let localStore = Store<LocalValue, LocalAction>(
//            initialValue: toLocalValue(value),
//            reducer: { localValue, localAction in
//                self.send(toGlobalAction(localAction))
//                localValue = toLocalValue(self.value)
//                return { .empty() }
//            }
//        )
//        localStore.cancellable = self.$value.sink { [weak localStore] newValue in
//            localStore?.value = toLocalValue(newValue)
//        }
//        return localStore
//    }
//    
//    public func view<LocalValue, LocalAction>(
//        value toLocalValue: @escaping (Value) -> LocalValue?,
//        action toGlobalAction: @escaping (LocalAction) -> Action
//    ) -> Store<LocalValue, LocalAction>? {
//        guard let localValue = toLocalValue(value) else { return nil }
//        let localStore = Store<LocalValue, LocalAction>(
//            initialValue: localValue,
//            reducer: { localValue, localAction in
//                self.send(toGlobalAction(localAction))
//                if let newLocalValue = toLocalValue(self.value) {
//                    localValue = newLocalValue
//                }
//                return { .empty() }
//            }
//        )
//        localStore.cancellable = self.$value.sink { [weak localStore] newValue in
//            if let newLocalValue = toLocalValue(newValue) {
//                localStore?.value =  newLocalValue
//            }
//        }
//        return localStore
//    }
//}

public func pullback<LocalValue, GlobalValue, LocalAction, GlobalAction>(
    _ reducer: @escaping Reducer<LocalValue, LocalAction>,
    value: WritableKeyPath<GlobalValue, LocalValue>,
    action: WritableKeyPath<GlobalAction, LocalAction?>
) -> Reducer<GlobalValue, GlobalAction> {
    return { globalValue, globalAction in
        guard let localAction = globalAction[keyPath: action] else { return [] }
        let localEffects = reducer(&globalValue[keyPath: value], localAction)
        
        return localEffects.map { localEffect in
            localEffect.map { localAction -> GlobalAction in
                var globalAction = globalAction
                globalAction[keyPath: action] = localAction
                return globalAction
            }
            .eraseToEffect()
        }
    }
}

public func pullback<LocalValue, GlobalValue, LocalAction, GlobalAction>(
    _ reducer: @escaping Reducer<LocalValue, LocalAction>,
    value: WritableKeyPath<GlobalValue, LocalValue?>,
    action: WritableKeyPath<GlobalAction, LocalAction?>
) -> Reducer<GlobalValue, GlobalAction> {
    return { globalValue, globalAction in
        guard let localAction = globalAction[keyPath: action] else { return [] }
        guard globalValue[keyPath: value] != nil else { return [] }
        let localEffects = reducer(&(globalValue[keyPath: value])!, localAction)
        
        return localEffects.map { localEffect in
            localEffect.map { localAction -> GlobalAction in
                var globalAction = globalAction
                globalAction[keyPath: action] = localAction
                return globalAction
            }
            .eraseToEffect()
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
) -> Reducer<Value, Action> {
    return { value, action in
        let effects = reducer(&value, action)
        let newValue = value
        return [.fireAndForget {
            print("Action: \(action)")
            print("Value:")
            dump(newValue)
            print("---")
        }] + effects
    }
}

public func persisting<Value: Codable, Action>(
    _ reducer: @escaping Reducer<Value, Action>,
    at url: URL
) ->  Reducer<Value, Action> {
    return { value, action in
        let effects = reducer(&value, action)
        let newValue = value
        return [.fireAndForget {
            try! JSONEncoder()
                .encode(newValue)
                .write(to: url)
        }] + effects
    }
}

extension Effect {
    public static func fireAndForget(work: @escaping () -> Void) -> Effect {
        return Deferred { () -> Empty<Output, Never> in
            work()
            return Empty(completeImmediately: true)
        }.eraseToEffect()
    }
}
