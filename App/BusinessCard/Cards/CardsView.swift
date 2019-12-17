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

enum Cards {}

extension UUID: Identifiable {
    public var id: UUID { self }
}

extension Cards {
    struct CardsView: View {
        @ObservedObject var store: Store<Cards.State, Cards.Action>
        private var shareCancellable: AnyCancellable? = nil
        
        public init(store: Store<Cards.State, Cards.Action>) {
            self.store = store
        }
        
        var body: some View {
            List {
                ForEach(store.value.cards) { card in
                    NavigationLink(
                        destination: self.store.view(
                            value: { $0.cards.first(where: { $0.id == card.id }).map(CardDetail.State.init) },
                            action: { .detail($0) }
                        ).map(CardDetailView.init)
                    ) { self.cardCell(card) }
                    
                }
                .onDelete { indexSet in
                    indexSet.forEach {
                        let id = self.store.value.cards[$0].id
                        self.store.send(.proposeCardDelete(id))
                    }
                }
            }.sheet(item: store.send(
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
                    self.store.send(.share(card.id))
                }
                Button("Delete") {
                    self.store.send(.proposeCardDelete(card.id))
                }
                .actionSheet(
                    item: self.store.send(
                        Cards.Action.proposeCardDelete,
                        binding: \.proposedCardDeleteID
                    )
                ) { id in
                    ActionSheet(
                        title: Text("Delete this card?"),
                        buttons: [
                            .destructive(Text("Delete")) {
                                self.store.send(.delete(id))
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
            reducer: Cards.reducer
            ))
        }
        
    }
}
#endif
