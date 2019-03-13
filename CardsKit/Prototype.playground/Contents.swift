
import Foundation



@testable import CardsKit
import UIKit
import PlaygroundSupport

extension Array where Element == Card {
    internal static var mock: [Card] {
        return [
            .init(
                firstName: "Luke",
                lastName: "Street",
                emailAddress: "ldstreet@me.com",
                phoneNumber: "574-904-1556",
                title: "Software Developer",
                address: "123 Somewhere Ave."
            ),
            .init(
                firstName: "David",
                lastName: "Street",
                emailAddress: "dastreet@me.com",
                phoneNumber: "555-555-5555",
                title: "Project Manager",
                address: "123 Somewhere Else St."
            ),
            .init(
                firstName: "Joe",
                lastName: "Shmo",
                emailAddress: "jshmo@me.com",
                phoneNumber: "555-555-5555",
                title: "Designer",
                address: "123 Somewhere Else Further Ln."
            ),
        ]
    }
}


let navigationController = UINavigationController()

let vc = CardsViewController.init(cards: .mock)
navigationController.setViewControllers([vc], animated: false)

let createCameraVC = CreateCardCameraViewController()

PlaygroundPage.current.liveView = createCameraVC


