//
//  ContentView.swift
//  BusinessCard
//
//  Created by Luke Street on 8/27/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import SwiftUI
import Redux

struct AppState: Codable {
    var cardsState: CardsState? = nil
    var createCardState: CreateCardState? = nil
}

enum AppAction {
    
    case cards(CardsAction)
    case create(CreateCardAction)
    case showCreateCard

    var cards: CardsAction? {
        get {
            guard case let .cards(value) = self else { return nil }
            return value
        }
        set {
            guard case .cards = self, let newValue = newValue else { return }
            self = .cards(newValue)
        }
    }

    var create: CreateCardAction? {
        get {
            guard case let .create(value) = self else { return nil }
            return value
        }
        set {
            guard case .create = self, let newValue = newValue else { return }
            self = .create(newValue)
        }
    }
}

let _appReducer: Reducer<AppState, AppAction> = { state, action in
    switch action {
    case .cards(_): break
    case .create(_): break
    case .showCreateCard:
        state.createCardState = CreateCardState()
    }
}

let appReducer: Reducer<AppState, AppAction> = combine(
    _appReducer,
    pullback(
        cardsReducer,
        value: \.cardsState,
        action: \.cards
    )
)

struct AppView: View {
    
    @ObservedObject var store: Store<AppState, AppAction>
    
    var body: some View {
        NavigationView {
            IfLet(store.value.cardsState) { cardsState in
                CardsView(
                    store: pullforward(
                        self.store,
                        localValue: cardsState,
                        value: \AppState.cardsState,
                        globalActionFromLocal: { return .cards($0) }
                    )
                )
            }
            .navigationBarTitle("Card Share")
            .navigationBarItems(
                trailing: NavigationLink(
                    destination: CreateCardView(
                        store: pullforward(
                            self.store,
                            localValue: CreateCardState(),
                            value: \AppState.createCardState,
                            globalActionFromLocal: { return .create($0) }
                        )
                    ),
                    label: { Text("Create Card") }
                )
            )
        }
    }
}

#if DEBUG
struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView(
            store: .init(
                initialValue: .init(cardsState: .init(description: "Woah...")),
                reducer: logging(appReducer)
            )
        )
    }
}
#endif
