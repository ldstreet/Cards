//
//  CardsView.swift
//  BusinessCard
//
//  Created by Luke Street on 8/31/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import SwiftUI
import Redux

enum Cards {}

extension UUID: Identifiable {
    public var id: UUID { self }
}

extension Cards {
    struct CardsView: View {
        @ObservedObject var store: Store<Cards.State, Cards.Action>
        
        var body: some View {
            List {
                ForEach(store.value.cards) { card in
                    CardPreviewView(card: card)
                        .contextMenu {
                            Button("Share"){}
                            Button("Delete"){
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
        }
    }
}


#if DEBUG
struct CardsView_Previews: PreviewProvider {
    static var previews: some View {
        Cards.CardsView(store: .init(initialValue: .init(cards: .all), reducer: Cards.reducer))
    }
}
#endif
