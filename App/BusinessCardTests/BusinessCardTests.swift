//
//  BusinessCardTests.swift
//  BusinessCardTests
//
//  Created by Luke Street on 8/27/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import XCTest
@testable import BusinessCard
import Models
#if DEBUG

class BusinessCardTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        let state = CreateCardState(card: Card.luke)
        assert(
            initialValue: App.State(cardsState: .init(), createCardState: .init(), showCreateCardCancelDialog: nil),
            reducer: navigation(cardsIO(App.reducer)),
            steps:
            .send(.updateCreateCardState(state)) { $0.createCardState = state },
            .send(.create(.done)) {
                $0.createCardState = nil
                $0.cardsState.cards.append(.luke)
            }
            
        )
    }

}

#endif
