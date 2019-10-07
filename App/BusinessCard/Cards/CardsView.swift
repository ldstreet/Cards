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
                    CardPreviewView(card: card)
                        .contextMenu {
                            Button("Share") {
                                self.store.asyncSend(.share(card.id))
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
                }.onDelete { indexSet in
                    indexSet.forEach {
                        let id = self.store.value.cards[$0].id
                        self.store.send(.proposeCardDelete(id))
                    }
                }
            }
            .sheet(item: store.dumbSend(binding: \.shareLink)) {  url in
                ActivityView(activityItems: [url.absoluteString], applicationActivities: nil)
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
        Cards.CardsView(store: .init(initialValue: .init(cards: .all), reducer: Cards.reducer, asyncReducer: Cards.asyncReducer))
    }
}
#endif
