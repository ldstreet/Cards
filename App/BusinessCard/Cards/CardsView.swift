//
//  CardsView.swift
//  BusinessCard
//
//  Created by Luke Street on 8/31/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import SwiftUI
import ComposableArchitecture
import Combine
import Models

enum Cards {
    struct Environment {}
}

extension UUID: Identifiable {
    public var id: UUID { self }
}

extension Cards {
    struct CardsView: View {
        private let store: Store<Cards.State, Cards.Action>
        
        private var shareCancellable: AnyCancellable? = nil
        
        init(store: Store<State, Action>) {
            self.store = store
        }
        
        var body: some View {
            WithViewStore(store) { viewStore in
                List {
                    self.cards()
                }.sheet(item: viewStore.binding(
                    get: \.shareLink,
                    send: Cards.Action.presentShareLink
                )) {  url in
                    ActivityView(activityItems: [url.absoluteString], applicationActivities: nil)
                }
            }
        }
        
        func cards() -> some View {
            WithViewStore(store) { viewStore in
                ForEachStore(
                    self.store.scope(
                        state: \.cards,
                        action: Cards.Action.detail
                    )
                ) { cardStore in
                    WithViewStore(cardStore) { cardViewStore in
                        NavigationLink(
                            destination: CardDetailView(store: cardStore),
                            tag: cardViewStore.id,
                            selection: viewStore.binding(
                                get: \.detailCardID,
                                send: Cards.Action.showDetail
                            ),
                            label: { self.cardCell(cardViewStore.state) }
                        )
                    }
                }
                .onDelete { indexSet in
                    indexSet.forEach {
                        let id = viewStore.cards[$0].id
                        viewStore.send(.proposeCardDelete(id))
                    }
                }
            }
        }
        
        func cardCell(_ card: Card) -> some View {
            WithViewStore(store) { viewStore in
                HStack {
                    CardPreviewView(card: card)
                    Spacer()
                }
                .contentShape(Rectangle())
                .contextMenu {
                    Button("Share") {
                        viewStore.send(.share(card.id))
                    }
                    Button("Delete") {
                        viewStore.send(.proposeCardDelete(card.id))
                    }
                    .actionSheet(
                        item: viewStore.binding(
                            get: \.proposedCardDeleteID,
                            send: Cards.Action.proposeCardDelete
                        )
                    ) { id in
                        ActionSheet(
                            title: Text("Delete this card?"),
                            buttons: [
                                .destructive(Text("Delete")) {
                                    viewStore.send(.delete(id))
                                },
                                .cancel()
                            ]
                        )
                    }
                }
                .transition(.scale(scale: 0, anchor: .center))
            }
        }
    }
}

extension URL: Identifiable {
    public var id: String { absoluteString }
}


#if DEBUG
struct CardsView_Previews: PreviewProvider {
    static var previews: some View {
        return Group {
            Cards.CardsView(store: .init(
                initialState: .init(cards: .all),
                reducer: Cards.reducer,
                environment: .init()
            ))
        }
        
    }
}
#endif
