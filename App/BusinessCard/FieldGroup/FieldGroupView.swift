//
//  FieldGroupView.swift
//  BusinessCard
//
//  Created by Luke Street on 1/13/20.
//  Copyright © 2020 Luke Street. All rights reserved.
//

import Foundation
import SwiftUI
import Models
import Redux

enum FieldGroup {
    
    struct Environment {}
    
    typealias State = Card.Group
    
    enum Action: Equatable {
        case fields(Indexed<FieldCell.Action>)

        var fields: Indexed<FieldCell.Action>? {
            get {
                guard case let .fields(value) = self else { return nil }
                return value
            }
            set {
                guard case .fields = self, let newValue = newValue else { return }
                self = .fields(newValue)
            }
        }
    }
    
    struct View: SwiftUI.View {
        
        private let store: Store<State, Action>
        @ObservedObject var viewStore: ViewStore<State, Action>
        
        init(store: Store<State, Action>) {
            self.store = store
            self.viewStore = store.view
        }
        
        var body: some SwiftUI.View {
            Section {
                ForEach(0..<viewStore.value.fields.count) { index in
                    FieldCell.View(
                        store: self.store.scope(
                            value: { $0.fields[index] },
                            action: { .fields(Indexed(index: index, value: $0)) }
                        )
                    )
                }
            }
        }
    }
    
    static let _reducer: Reducer<State, Action, Environment> = { state, action, environment in
        switch action {
        case .fields: break
        }
        return []
    }
    
    static let reducer: Reducer<State, Action, Environment> = combine(
        _reducer,
        indexed(
            reducer: FieldCell.reducer,
            \State.fields,
            \Action.fields,
            { _ in .init() }
        )
    )
}
