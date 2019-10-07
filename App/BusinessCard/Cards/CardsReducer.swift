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
    static let reducer: Reducer<Cards.State, Cards.Action> = { state, action in
        switch action {
        case .delete(let id):
            state.cards.removeAll { $0.id == id }
        case .proposeCardDelete(let id):
            state.proposedCardDeleteID = id
            state.showConfirmDelete = id != nil
        case .share(let id):
            guard let card = state.cards.first(where: { $0.id == id }) else { return }
            state.loading = true

        }
    }
    
    static let asyncReducer: AsyncReducer<Cards.State, Cards.Action> = { getState, action in
        switch action {
        case .delete(_): break
        case .proposeCardDelete(_): break
        case .share(let id):
            guard let card = getState().cards.first(where: { $0.id == id }) else {
                return Just(getState()).eraseToAnyPublisher()
            }
            return Request<Environment, Card>
                .share(card: card)
                .send()
                .eraseToAnyPublisher()
                .catch { (error) -> Just<ShareLink> in
                    return Just(ShareLink(path: ""))
                }.map { sharePath in
                    var futureState = getState()
                    futureState.shareLink = Current.environment.url.appendingPathComponent(sharePath.path)
                    futureState.loading = false
                    return futureState
                }.eraseToAnyPublisher()
//                .sink(receiveCompletion: { completion in
//                    var futureState = getState()
//                    switch completion {
//                    case .finished:
//                        futureState.loading = false
//                    case .failure(let error):
//                        futureState.loading = false
//                    }
//                    subject.send(futureState)
//                }) { sharePath in
//                    var futureState = getState()
//                    futureState.shareLink = Current.environment.url.appendingPathComponent(sharePath)
//                    subject.send(futureState)
//                }
        }
        return Just(getState()).eraseToAnyPublisher()
    }
}
