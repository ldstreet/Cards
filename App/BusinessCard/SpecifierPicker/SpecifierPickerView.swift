//
//  SpecifierPickerView.swift
//  BusinessCard
//
//  Created by Luke Street on 1/6/20.
//  Copyright © 2020 Luke Street. All rights reserved.
//

import SwiftUI
import Redux

enum SpecifierPicker {
    struct Environment {
        
    }
}

extension SpecifierPicker {
    struct View: SwiftUI.View {
        
        private let store: Store<State, Action>
        @ObservedObject var viewStore: ViewStore<State, Action>
        
        init(store: Store<State, Action>) {
            self.store = store
            self.viewStore = store.view
        }
        
        var body: some SwiftUI.View {
            Picker(
                "",
                selection: viewStore.send(
                    SpecifierPicker.Action.selected,
                    binding: \.selection
                )
            ) {
                ForEach(
                    viewStore.value.specifiers.enumeratedArray(),
                    id: \.offset
                ) { Text($0.element) }
            }
        }
    }
}


struct SpecifierPicker_Previews: PreviewProvider {
    static var previews: some View {
        let specifiers = ["home", "cell", "work"]
        return SpecifierPicker.View(
            store: .init(
                initialValue: SpecifierPicker.State(specifiers: specifiers, selection: specifiers.startIndex),
                reducer: SpecifierPicker.reducer,
                environment: .init()
            )
        ).previewLayout(.sizeThatFits)
    }
}
