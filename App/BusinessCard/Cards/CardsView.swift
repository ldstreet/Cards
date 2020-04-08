//
//  CardsView.swift
//  BusinessCard
//
//  Created by Luke Street on 8/31/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import SwiftUI
import Redux
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
        @ObservedObject var viewStore: ViewStore<Cards.State, Cards.Action>
        
        
        private var shareCancellable: AnyCancellable? = nil
        
        init(store: Store<State, Action>) {
            self.store = store
            self.viewStore = store.view
        }
        
        var body: some View {
            List {
                ForEach(viewStore.value.cards) { card in
                    NavigationLink(
                        destination: self.store.scope(
                            value: { $0.cards.first(where: { $0.id == card.id }).map(CardDetail.State.init) },
                            action: { .detail($0) }
                        ).map(CardDetailView.init)
                    ) { self.cardCell(card) }
                    
                }
                .onDelete { indexSet in
                    indexSet.forEach {
                        let id = self.viewStore.value.cards[$0].id
                        self.viewStore.send(.proposeCardDelete(id))
                    }
                }
            }.sheet(item: viewStore.send(
                Cards.Action.presentShareLink,
                binding: \Cards.State.shareLink
            )) {  url in
                ActivityView(activityItems: [url.absoluteString], applicationActivities: nil)
            }
        }
        
        func cardCell(_ card: Card) -> some View {
            HStack {
                CardPreviewView(card: card)
                Spacer()
            }
            .contentShape(Rectangle())
            .contextMenu {
                Button("Share") {
                    self.viewStore.send(.share(card.id))
                }
                Button("Delete") {
                    self.viewStore.send(.proposeCardDelete(card.id))
                }
                .actionSheet(
                    item: self.viewStore.send(
                        Cards.Action.proposeCardDelete,
                        binding: \.proposedCardDeleteID
                    )
                ) { id in
                    ActionSheet(
                        title: Text("Delete this card?"),
                        buttons: [
                            .destructive(Text("Delete")) {
                                self.viewStore.send(.delete(id))
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

extension URL: Identifiable {
    public var id: String { absoluteString }
}


#if DEBUG
struct CardsView_Previews: PreviewProvider {
    static var previews: some View {
        return Group {
            Cards.CardsView(store: .init(
                initialValue: .init(cards: .all),
                reducer: Cards.reducer,
                environment: .init()
            ))
        }
        
    }
}
#endif
