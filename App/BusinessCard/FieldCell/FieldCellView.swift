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
import Redux

enum FieldCell {
    struct View: SwiftUI.View {
        
        let store: Store<State, Action>
        
        var body: some SwiftUI.View {
            HStack {
                store.value.type.specifiers.map { specifiers in
                    SpecifierPicker.View(store: store.view(value: { state in
                        let selectionIndex = specifiers.firstIndex { state.specifier == $0 } ?? specifiers.startIndex
                        return SpecifierPicker.State(specifiers: specifiers, selection: selectionIndex)
                    }, action: { localAction in
                        return .specifierUpdate(localAction)
                    }))
                }.fixedSize()
                
                Divider()
                
                TextField(
                    store.value.type.rawValue,
                    text: store.send(
                        Action.update,
                        binding: \.value
                    )
                )
            }
        }
    }
    
    typealias State = Card.Field
    
    enum Action: Equatable {
        case update(value: String)
        case specifierUpdate(SpecifierPicker.Action)

        var update: String? {
            get {
                guard case let .update(value) = self else { return nil }
                return value
            }
            set {
                guard case .update = self, let newValue = newValue else { return }
                self = .update(value: newValue)
            }
        }

        var specifierUpdate: SpecifierPicker.Action? {
            get {
                guard case let .specifierUpdate(value) = self else { return nil }
                return value
            }
            set {
                guard case .specifierUpdate = self, let newValue = newValue else { return }
                self = .specifierUpdate(newValue)
            }
        }
    }
    
    static let _reducer: Reducer<State, Action> = { state, action in
        switch action {
        case .update(let value):
            state.value = value
        case .specifierUpdate: break
        }
        return []
    }
    
    static let reducer: Reducer<State, Action> = combine(
        _reducer,
        pullback(
            SpecifierPicker.reducer,
            value: \.specifierPickerState,
            action: \.specifierUpdate
        )
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

struct FieldCell_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Form {
                FieldCell.View(
                    store: .init(
                        initialValue: FieldCell.State(
                            type: .phoneNumber,
                            specifier: "cell",
                            value: "555-555-5555"
                        ),
                        reducer: FieldCell.reducer
                    )
                )
                .previewLayout(.sizeThatFits)
            }
        }
    }
}
