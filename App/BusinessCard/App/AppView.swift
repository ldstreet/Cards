//
//  ContentView.swift
//  BusinessCard
//
//  Created by Luke Street on 8/27/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import SwiftUI
import Redux

enum App {}

struct AppView: View {
    
    @ObservedObject var store: Store<App.State, App.Action>
    @State var showCreateCard = false
    
    var body: some View {
        NavigationView {
            EmptyView()
            IfLet(store.value.cardsState) { cardsState in
                Cards.CardsView(
                    store: pullforward(
                        self.store,
                        value: \App.State.cardsState,
                        globalActionFromLocal: { return .cards($0) }
                    )
                )
            }
            .navigationBarTitle("Card Share")
            .navigationBarItems(
                trailing: Button(
                    action: { self.store.send(.showCreateCard(true)) },
                    label: { Image(systemName: "plus").font(.title) }
                    )
            )
        }.sheet(
            isPresented: store.send(
                App.Action.showCreateCard,
                binding: \App.State.showCreateCard
            ),
            onDismiss: {
                self.store.send(.confirmCreateCardCancel(true))
            },
            content: {
                return CreateCardView(
                    store: pullforward(
                        self.store,
                        value: \.createCardState,
                        globalActionFromLocal: { return .create($0) }
                    )
                )
            }
        )
        .actionSheet(
            isPresented: store.send(
                App.Action.confirmCreateCardCancel,
                binding: \.showCreateCardCancelDialog
            ),
            content: {
                ActionSheet(
                    title: Text("Are you shure you want to discard this new business card?"),
                    buttons: [
                        .destructive(Text("Discard Changes")) {
                            self.store.send(.create(.cancel))
                        },
                        .default(Text("Keep Editing")) {
                            self.store.send(.showCreateCard(true))
                        }
                    ]
                )
            }
        )
    }
}

#if DEBUG
struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView(
            store: .init(
                initialValue: .init(cardsState: .init(cards: .all)),
                reducer: logging(navigation(cardsIO(App.reducer)))
            )
        )
    }
}
#endif
