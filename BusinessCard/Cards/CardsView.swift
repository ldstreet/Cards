//
//  CardsView.swift
//  BusinessCard
//
//  Created by Luke Street on 8/31/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import SwiftUI
import Redux

struct CardsState: Codable {
    var description: String
    var didIt = false
}

enum CardsAction {
    case doIt
}

let cardsReducer: Reducer<CardsState, CardsAction> = { state, action in
    switch action {
    case .doIt:
        if state.didIt == true {
            state.description = "Just Do It"
        } else {
            state.description = "Did it!"
        }
        state.didIt.toggle()
    }
}

struct CardsView: View {
    @ObservedObject var store: Store<CardsState, CardsAction>
    
    var body: some View {
        VStack {
            Text(store.value.description)
            Button(
                action: { self.store.send(.doIt) },
                label: { Text("Just Do It") }
            )
            Text("Always here...")
        }
        
    }
}

#if DEBUG
struct CardsView_Previews: PreviewProvider {
    static var previews: some View {
        CardsView(store: .init(initialValue: .init(description: "Do it"), reducer: cardsReducer))
    }
}
#endif
