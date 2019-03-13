//
//  World.swift
//  CardsKit
//
//  Created by Luke Street on 2/14/19.
//

#if os(iOS)
import Foundation
import LDSiOSKit
import UIKit

public struct World {
    var environment: Environment = {
        guard
            let environmentString = Bundle.main.object(forInfoDictionaryKey: "environment") as? String,
            let environment = Environment(rawValue: environmentString)
        else { return Environment.develop }
        
        return environment
    }()
    
    var date: () -> Date = Date.init
    
    public var makeInitialVieWController: () -> UIViewController = {
        return CardsViewController(cards: [])
    }
    

    //
    //        let tagger = NLTagger(tagSchemes: [.nameType])
    //        tagger.string = text
    //        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace, .joinNames]
    //        let tags: [NLTag] = [.personalName, .placeName, .organizationName]
    //        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .nameType, options: options) { tag, tokenRange in
    //            if let tag = tag, tags.contains(tag) {
    //                print("\(text[tokenRange]): \(tag.rawValue)")
    //            }
    //            return true
    //        }
    
    public let createCardBuilder: (String) throws -> CardBuilder = { text in
        let transformations: [(String) -> CardBuilder] = [
            detectAddressAndPhoneNumberAndEmail
        ]
        return transformations.reduce(CardBuilder(), { (builder, transformation) -> CardBuilder in
            return builder.appending(transformation(text))
        })
    }
}

func detectAddressAndPhoneNumberAndEmail(from text: String) -> CardBuilder {
    var cardBuilder = CardBuilder()
    let detector = try? NSDataDetector(
        types: NSTextCheckingResult.CheckingType.address.rawValue |
            NSTextCheckingResult.CheckingType.phoneNumber.rawValue
    )
    detector?.enumerateMatches(in: text, range: NSMakeRange(0, text.count), using: { (match, flag, bool) in
        guard let match = match else { return }
        switch match.resultType {
        case NSTextCheckingResult.CheckingType.address:
            cardBuilder.address = match.addressComponents?[.street]
        case NSTextCheckingResult.CheckingType.phoneNumber:
            cardBuilder.phoneNumber = match.phoneNumber
        case NSTextCheckingResult.CheckingType.link:
            if match.url?.scheme == "mailto" {
                cardBuilder.emailAddress = match.url?.absoluteString
            }
        default:
            print("None")
        }
    })
    return cardBuilder
}

public let Current = World()

public struct AlienWorld {
    
    public let convert: (UIImage, @escaping ResultClosure<String>) -> Void
    
    public init(convert: @escaping (UIImage, @escaping ResultClosure<String>) -> Void) {
        self.convert = convert
    }
}

private var alien: AlienWorld?

public var Alien: AlienWorld {
    get {
        guard let alien = alien else {
            fatalError("Alien has not been set up. Please configure.")
        }
        return alien
    }
    set {
        precondition(alien == nil, "Alien has already been set! This object can only be set once.")
        alien = newValue
    }
}

#endif

