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
        
//        func showDetail(for card: Card) -> Bool {
//            self.store.value.showDetail == card.id
//        }
        
        var body: some View {
            List {
                ForEach(store.value.cards) { card in
                    if self.store.value.detailCardID == card.id {
                        self.store.view(
                            value: { $0.detailCard },
                            action: { .detail($0) }
                        )
                            .map(CardDetailView.init)?
                            .tag(card.id)
//                            .id(card.id)
                            .onTapGesture {
                                withAnimation {
                                    self.store.send(.showDetail(nil))
                                }
                            }
                        .transition(.move(edge: .top))
                            
                    } else {
                        self.cardPreview(card)
                            .tag(card.id)
//                            .id(card.id)
                            .transition(.move(edge: .top))
                            
                    }
                    
                    
                }
                .onDelete { indexSet in
                    indexSet.forEach {
                        let id = self.store.value.cards[$0].id
                        self.store.send(.proposeCardDelete(id))
                    }
                }
            }
            .sheet(item: store.send(
                Cards.Action.presentShareLink,
                binding: \Cards.State.shareLink
            )) {  url in
                ActivityView(activityItems: [url.absoluteString], applicationActivities: nil)
            }.listStyle(GroupedListStyle())
        }
        
        func cardPreview(_ card: Card) -> some View {
            CardPreviewView(card: card)
                .onTapGesture {
                    withAnimation {
                        self.store.send(.showDetail(card.id))
                    }
                }
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
        }
    }
}

extension URL: Identifiable {
    public var id: String { absoluteString }
}


#if DEBUG
struct CardsView_Previews: PreviewProvider {
    static var previews: some View {
        Cards.CardsView(store: .init(
            initialValue: .init(cards: .all),
            reducer: Cards.reducer
        )).animation(.default)
    }
}
#endif
