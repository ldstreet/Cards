//
//  CardsReducer.swift
//  BusinessCard
//
//  Created by Luke Street on 9/1/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import Redux
import Models
import Combine

extension Cards {
    static let reducer: Reducer<State, Action> = { state, action in
        switch action {
        case .delete(let id):
            state.cards.removeAll { $0.id == id }
        case .proposeCardDelete(let id):
            state.proposedCardDeleteID = id
            state.showConfirmDelete = id != nil
        case .presentShareLink(let link):
            state.loading = false
            state.shareLink = link
        case .share(let id):
            state.loading = true
            let newState = state
            guard let card = state.cards.first(where: { $0.id == id }) else { break }
            return [Request<Environment, ShareLink, Card>
                .share(card: card)
                .send()
                .eraseToAnyPublisher()
                .catch { (error) -> Just<ShareLink> in
                    print(error)
                    return Just(ShareLink(path: ""))
                }.map { sharePath in
                    let link = Current.environment.url.appendingPathComponent(sharePath.path)
                    return Cards.Action.presentShareLink(link)
                }.eraseToEffect()]
        case .showDetail(let id):
            state.detailCardID = id
        case .detail(_): break
        }
        return []
    }
}
