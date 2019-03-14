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
    
    public let createCardBuilder: (String) throws -> CardBuilder = { text in
        let transformations: [(String) -> CardBuilder] = [
            detectAddressAndPhoneNumberAndEmail,
            detectName
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
            NSTextCheckingResult.CheckingType.phoneNumber.rawValue |
            NSTextCheckingResult.CheckingType.link.rawValue
        
    )
    detector?.enumerateMatches(in: text, range: NSMakeRange(0, text.count), using: { (match, flag, bool) in
        guard let match = match else { return }
        switch match.resultType {
        case NSTextCheckingResult.CheckingType.address:
            cardBuilder.address = """
            \(match.addressComponents![.street] ?? "")
            \(match.addressComponents![.city] ?? ""), \(match.addressComponents![.state] ?? "") \(match.addressComponents![.zip] ?? "")
            """
        case NSTextCheckingResult.CheckingType.phoneNumber:
            let prevRange = text.range(from: match.adjustingRanges(offset: -5).range)!
            let prevStr = text[prevRange].lowercased()
            let cellPrefixes = ["cell", "mob", "mobile"]
            let isCell = cellPrefixes.reduce(false, { res, prefix in return res || prevStr.contains(prefix) })
            if isCell {
                print("cell: \(match.phoneNumber ?? "")")
            }
            
            let workPrefixes = ["work", "tel", "office"]
            let ifWork = workPrefixes.reduce(false, { res, prefix in return res || prevStr.contains(prefix) })
            if ifWork {
                print("work: \(match.phoneNumber ?? "")")
            }
            
            let faxPrefixes = ["fax", "fx"]
            let isFax = faxPrefixes.reduce(false, { res, prefix in return res || prevStr.contains(prefix) })
            if isFax {
                print("fax: \(match.phoneNumber ?? "")")
            }
            
            cardBuilder.phoneNumber = match.phoneNumber
            
        case NSTextCheckingResult.CheckingType.link:
            if
                let url = match.url,
                match.url?.scheme == "mailto"
            {
                let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
                let email = components?.path
                cardBuilder.emailAddress = email?.lowercased()
            }
        default:
            print("None")
        }
    })
    return cardBuilder
}

import NaturalLanguage
func detectName(from text: String) -> CardBuilder {
    let tagger = NLTagger(tagSchemes: [.nameType])
    tagger.string = text
    let options: NLTagger.Options = [.joinNames]
    
    var cardBulder = CardBuilder()
    tagger
        .tags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .nameType, options: options)
        .forEach { pair in
            let (tag, range) = pair
            
            if tag == NLTag.organizationName {
                print("organization: \(text[range])")
            }
            guard tag == NLTag.personalName else { return }
            let nameArray = String(text[range]).split(separator: " ").compactMap(String.init)
            guard nameArray.count == 2 else { return }
            cardBulder.firstName = nameArray.first
            cardBulder.lastName = nameArray.last
    }
    
    return cardBulder
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

extension String {
    func range(from nsRange: NSRange) -> Range<String.Index>? {
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location + nsRange.length, limitedBy: utf16.endIndex),
            let from = from16.samePosition(in: self),
            let to = to16.samePosition(in: self)
            else { return nil }
        return from ..< to
    }
}

#endif

