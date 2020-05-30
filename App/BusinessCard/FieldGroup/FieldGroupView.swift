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
import ComposableArchitecture

enum FieldGroup {
    
    struct Environment {}
    
    typealias State = Card.Group
    
    enum Action: Equatable {
        case fields(Int, FieldCell.Action)
        case addNewField
        case removeFields(in: IndexSet)
    }
    
    struct View: SwiftUI.View {
        
        private let store: Store<State, Action>
        
        init(store: Store<State, Action>) {
            self.store = store
        }
        
        var body: some SwiftUI.View {
            Section {
                WithViewStore(store) { viewStore in
                    ForEachStore(
                        self.store.scope(
                            state: \.fields,
                            action: FieldGroup.Action.fields
                        ),
                        content: FieldCell.View.init
                    ).onDelete { indexSet in
                        viewStore.send(.removeFields(in: indexSet))
                    }
                    Button(action: {
                        viewStore.send(.addNewField)
                    }) {
                        HStack {
                            Image(systemName: "plus").foregroundColor(Color.green)
                            Text("\(viewStore.type.rawValue)")
                        }
                    }
                }
            }
        }
    }
    
    static let reducer: Reducer<State, Action, Environment> = .init { state, action, environment in
        switch action {
        case .fields: break
        case .addNewField:
            state.fields.append(.init(type: state.type, specifier: "", value: ""))
        case .removeFields(let indexSet):
            indexSet.forEach { state.fields.remove(at: $0) }
        }
        return .none
    }
}
