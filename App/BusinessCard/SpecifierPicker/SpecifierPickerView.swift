//
//  SpecifierPickerView.swift
//  BusinessCard
//
//  Created by Luke Street on 1/6/20.
//  Copyright © 2020 Luke Street. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

enum SpecifierPicker {
    struct Environment {
        
    }
}

extension SpecifierPicker {
    struct View: SwiftUI.View {
        
        private let store: Store<State, Action>
        
        init(store: Store<State, Action>) {
            self.store = store
        }
        
        var body: some SwiftUI.View {
            WithViewStore(store) { viewStore in
                Picker(
                    "",
                    selection: viewStore.binding(
                        get: \.selection,
                        send: SpecifierPicker.Action.selected
                    )
                ) {
                    ForEach(
                        viewStore.specifiers.enumeratedArray(),
                        id: \.offset
                    ) { Text($0.element) }
                }
            }
            
        }
    }
}


//struct SpecifierPicker_Previews: PreviewProvider {
//    static var previews: some View {
//        let specifiers = ["home", "cell", "work"]
//        return SpecifierPicker.View(
//            store: .init(
//                initialValue: SpecifierPicker.State(specifiers: specifiers, selection: specifiers.startIndex),
//                reducer: SpecifierPicker.reducer,
//                environment: .init()
//            )
//        ).previewLayout(.sizeThatFits)
//    }
//}
