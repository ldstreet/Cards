
import Foundation
@testable import CardsKit
import UIKit
import PlaygroundSupport

extension Array where Element == Card {
    internal static var mock: [Card] {
        return [
            .mock
        ]
    }
}

extension Card {
    internal static var mock: Card {
        return
            Card(
                names: ["Luke Street"],
                emailAddresses: [.init(type: .personal, value: "ldstreet@me.com")],
                phoneNumbers: [.init(type: .cell, value: "574-904-1556")],
                titles: ["Software Developer"],
                addresses: [.init(type: .home, value: "123 Somewhere Ave.")]
        )
    }
}


//let navigationController = UINavigationController()

let vc = CreateCardViewController(card: .init()) { (card) in
    print(card)
}

//let createCardVC = CreateCardViewController(card: .mock, completion: {_ in })
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = vc


