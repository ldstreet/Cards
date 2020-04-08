//
//  TextIdentifier.swift
//  BusinessCard
//
//  Created by Luke Street on 1/27/20.
//  Copyright © 2020 Luke Street. All rights reserved.
//

import Foundation
import Models

func detectAddressAndPhoneNumberAndEmail(from text: String) -> [Card.FieldType : [String]] {
    var results = [Card.FieldType : [String]]()
    let detector = try? NSDataDetector(
        types: NSTextCheckingResult.CheckingType.address.rawValue |
            NSTextCheckingResult.CheckingType.phoneNumber.rawValue |
            NSTextCheckingResult.CheckingType.link.rawValue
        
    )
    detector?.enumerateMatches(in: text, range: NSMakeRange(0, text.count), using: { (match, flag, bool) in
        guard let match = match else { return }
        switch match.resultType {
        case .address:
            let address = """
            \(match.addressComponents![.street] ?? "")
            \(match.addressComponents![.city] ?? ""), \(match.addressComponents![.state] ?? "") \(match.addressComponents![.zip] ?? "")
            """
            if results[.address] != nil {
                results[.address]?.append(address)
            } else {
                results[.address] = [address]
            }
        case .phoneNumber:
            guard let phoneNumber = match.phoneNumber else { return }
//            let prevRange = text.range(from: match.adjustingRanges(offset: -5).range)!
//            let prevStr = text[prevRange].lowercased()
            
//            let cellPrefixes = ["cell", "mob", "mobile"]
//            let isCell = cellPrefixes.reduce(false, { res, prefix in return res || prevStr.contains(prefix) })
//            if isCell {
//                results[.phoneNumber] = phoneNumber
//            }
//
//            let workPrefixes = ["work", "tel", "office"]
//            let isWork = workPrefixes.reduce(false, { res, prefix in return res || prevStr.contains(prefix) })
//            if isWork {
//                results[.phoneNumber] = phoneNumber
//            }
//
//            let homePrefixes = ["home"]
//            let isHome = homePrefixes.reduce(false, { res, prefix in return res || prevStr.contains(prefix) })
//            if isHome {
//                results[.phoneNumber] = phoneNumber
//            }
//
//            let faxPrefixes = ["fax", "fx"]
//            let isFax = faxPrefixes.reduce(false, { res, prefix in return res || prevStr.contains(prefix) })
//            if isFax {
//
//            }
            if results[.phoneNumber] != nil {
                results[.phoneNumber]?.append(phoneNumber)
            } else {
                results[.phoneNumber] = [phoneNumber]
            }
            
        case .link:
            guard let url = match.url else { return }
            if
                match.url?.scheme == "mailto"
            {
                guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }
                let email = components.path
                if results[.emailAddress] != nil {
                    results[.emailAddress]?.append(email)
                } else {
                    results[.emailAddress] = [email]
                }
            }
        default:
            print("None")
        }
    })
    return results
}

import NaturalLanguage
func detectName(from text: String) -> [String] {
    let tagger = NLTagger(tagSchemes: [.nameType])
    tagger.string = text
    let options: NLTagger.Options = [.joinNames]

    return tagger
        .tags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .nameType, options: options)
        .compactMap { pair in
            let (tag, range) = pair
            
            if tag == NLTag.organizationName {
                print("organization: \(text[range])")
            }
            let name = String(text[range])
            guard tag == NLTag.personalName else { return nil }
//            let nameArray = String(name).split(separator: " ").compactMap(String.init)
//            guard nameArray.count == 2 else { return nil }
            return name
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
