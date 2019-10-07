//
//  Requests.swift
//  BusinessCard
//
//  Created by Luke Street on 9/30/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import Foundation
import Models

extension Request {
    
    static func share(card: Card) -> Request<Environment, ShareLink> {
        return .init(
            using: Current.environment,
            path: "share",
            method: HTTPMethod.post(body: try? card.encode()),
            headers: [:],
            session: .shared
        )
    }
}
