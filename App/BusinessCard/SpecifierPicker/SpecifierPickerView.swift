//
//  SpecifierPickerView.swift
//  BusinessCard
//
//  Created by Luke Street on 1/6/20.
//  Copyright © 2020 Luke Street. All rights reserved.
//

import SwiftUI
import Redux

enum SpecifierPicker {}

extension SpecifierPicker {
    struct View: SwiftUI.View {
        
        let store: Store<State, SpecifierPicker.Action>
        
        var body: some SwiftUI.View {
            Picker(
                "",
                selection: store.send(
                    SpecifierPicker.Action.selected,
                    binding: \.selection
                )
            ) {
                ForEach(
                    store.value.specifiers.enumeratedArray(),
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
                reducer: SpecifierPicker.reducer
            )
        ).previewLayout(.sizeThatFits)
    }
}
