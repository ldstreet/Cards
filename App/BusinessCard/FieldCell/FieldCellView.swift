//
//  FieldCellView.swift
//  BusinessCard
//
//  Created by Luke Street on 1/6/20.
//  Copyright © 2020 Luke Street. All rights reserved.
//

import Foundation
import SwiftUI
import Models
import ComposableArchitecture

enum FieldCell {
    
    struct Environment {
        
    }
    
    struct View: SwiftUI.View {
        
        let store: Store<State, Action>
        
        init(store: Store<State, Action>) {
            self.store = store
        }
        
        var body: some SwiftUI.View {
            WithViewStore(store) { viewStore in
                HStack {
                    
                    viewStore.type.specifiers.map { specifiers in
                        SpecifierPicker.View(store: self.store.scope(state: { state in
                            let selectionIndex = specifiers.firstIndex { state.specifier == $0 } ?? specifiers.startIndex
                            return SpecifierPicker.State(specifiers: specifiers, selection: selectionIndex)
                        }, action: { localAction in
                            return .specifierUpdate(localAction)
                        }))
                    }.fixedSize()

                    Divider()
                    
                    TextField(
                        viewStore.type.rawValue,
                        text: viewStore.binding(
                          get: \.value,
                          send: Action.update
                        )
                    )
                }
            }
        }
    }
    
    typealias State = Card.Field
    
    enum Action: Equatable {
        case update(value: String)
        case specifierUpdate(SpecifierPicker.Action)
    }
    
    static let reducer: Reducer<State, Action, Environment> =  Reducer<State, Action, Environment>.combine(
        SpecifierPicker.reducer.optional.pullback(
            state: \.specifierPickerState,
            action: /Action.specifierUpdate,
            environment: { _ in SpecifierPicker.Environment() }
        ),
        .init { state, action, environment in
            switch action {
            case .update(let value):
                state.value = value
            case .specifierUpdate: break
            }
            return .none
        }
    )
}

extension FieldCell.State {
    var specifierPickerState: SpecifierPicker.State? {
        get {
            guard let specifiers = type.specifiers else { return nil }
            return SpecifierPicker.State(specifiers: specifiers, selection: specifiers.firstIndex(of: specifier) ?? 0)
        }
        set {
            guard
                let specifiers = type.specifiers,
                let index = newValue?.selection,
                specifiers.indices.contains(index)
            else { return }
            self.specifier = specifiers[index]
        }
    }
}

//struct FieldCell_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            Form {
//                FieldCell.View(
//                    store: .init(
//                        initialState: FieldCell.State(
//                            type: .phoneNumber,
//                            specifier: "cell",
//                            value: "555-555-5555"
//                        ),
//                        reducer: FieldCell.reducer,
//                        environment: .init()
//                    )
//                )
//                .previewLayout(.sizeThatFits)
//            }
//        }
//    }
//}
