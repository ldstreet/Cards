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
        
        let store: Store<State, Action>
        
        var body: some SwiftUI.View {
            Section {
                ForEach(0..<store.value.fields.count) { index in
                    FieldCell.View(
                        store: self.store.view(
                            value: { $0.fields[index] },
                            action: { .fields(Indexed(index: index, value: $0)) }
                        )
                    )
                }
            }
        }
    }
    
    static let _reducer: Reducer<State, Action> = { state, action in
        switch action {
        case .fields: break
        }
        return []
    }
    
    static let reducer: Reducer<State, Action> = combine(
        _reducer,
        indexed(
            reducer: FieldCell.reducer,
            \State.fields,
            \Action.fields
        )
    )
}
