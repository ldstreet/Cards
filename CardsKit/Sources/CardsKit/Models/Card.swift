import Foundation

public enum EmailType: String, DataType {
    case work
    case personal
    case other
}

public enum PhoneType: String, DataType {
    case cell
    case work
    case home
    case fax
    case other
}

public protocol DataType: CaseIterable, RawRepresentable, Codable {}

extension DataType {
    public static var types: [RawValue] {
        return allCases.map { $0.rawValue }
    }
}

public enum AddressType: String, DataType {
    case work
    case home
    case other
}

//public enum CardError: Error {
//    case invalidCard
//    case missingRequiredFields
//}
//public struct Card: Codable {
//    var fieldGroups: [FieldGroup]
//    
//    var fields: [Field] {
//        return fieldGroups.flatMap { $0.fields }
//    }
//
//    func validated() throws -> Card {
//        let valid = fieldGroups.allSatisfy { group in
//            if group.required {
//                return group.fields.allSatisfy { $0.value != nil }
//            }
//            return true
//        }
//        guard valid else { throw CardError.invalidCard }
//        return self
//    }
//
//    var cleaned: Card {
//        let cleanedGroups = fieldGroups.compactMap { group in
//            guard !group.required else { return group }
//            group.fields.compactMap { }
//        }
//    }
//
//    func resolve(from template: Card) {
//
//    }
//
//    subscript(key: String) -> Field? {
//        get {
//            return fields.first(where: { $0.key == key })
//        }
//        set {
//            guard let newField = newValue else { return }
//            guard let index = fields.firstIndex(where: { $0.key == key }) else {
//                fields.append(newField)
//                return
//            }
//            fields[index] = newField
//        }
//    }
//}

public struct TypePair<Type: DataType, Value: Codable>: Codable {
    public let type: Type
    public let value: Value
    
    public init(_ type: Type, _ value: Value) {
        self.type = type
        self.value = value
    }
}


public struct Card: Codable {
    public var names: [String]
    public var emailAddresses: [TypePair<EmailType, String>]
    public var phoneNumbers: [TypePair<PhoneType, String>]
    public var titles: [String]
    public var addresses: [TypePair<AddressType, String>]
    public var uuid = UUID()

    public init(
        names: [String] = [],
        emailAddresses: [TypePair<EmailType, String>] = [],
        phoneNumbers: [TypePair<PhoneType, String>] = [],
        titles: [String] = [],
        addresses: [TypePair<AddressType, String>] = []
    )
    {
        self.names = names
        self.emailAddresses = emailAddresses
        self.phoneNumbers = phoneNumbers
        self.titles = titles
        self.addresses = addresses
    }

    public func appending(card: Card) -> Card {
        return Card(
            names: names + card.names,
            emailAddresses: emailAddresses + card.emailAddresses,
            phoneNumbers: phoneNumbers + card.phoneNumbers,
            titles: titles + card.titles,
            addresses: addresses + card.addresses
        )
    }
}

//public struct CardBuilder {
//    public var firstName: String?
//    public var lastName: String?
//    public var emailAddress: String?
//    public var phoneNumber: String?
//    public var title: String?
//    public var address: String?
//    public var uuid: UUID = .init()
//
//    public init(
//        firstName: String? = nil,
//        lastName: String? = nil,
//        emailAddress: String? = nil,
//        phoneNumber: String? = nil,
//        title: String? = nil,
//        address: String? = nil
//        )
//    {
//        self.firstName = firstName
//        self.lastName = lastName
//        self.emailAddress = emailAddress
//        self.phoneNumber = phoneNumber
//        self.title = title
//        self.address = address
//    }
//
//    func appending(_ builder: CardBuilder) -> CardBuilder {
//        return .init(
//            firstName: firstName ?? builder.firstName,
//            lastName: lastName ?? builder.lastName,
//            emailAddress: emailAddress ?? builder.emailAddress,
//            phoneNumber: phoneNumber ?? builder.phoneNumber,
//            title: title ?? builder.title,
//            address: address ?? builder.address
//        )
//    }
//
//    func build() throws -> Card {
//        return Card(
//            firstName: try firstName.unwrap(elseThrow: IncompleteCardBuilder(missing: "firstName")),
//            lastName: try lastName.unwrap(elseThrow: IncompleteCardBuilder(missing: "lastName")),
//            emailAddress: try emailAddress.unwrap(elseThrow: IncompleteCardBuilder(missing: "emailAddress")),
//            phoneNumber: try phoneNumber.unwrap(elseThrow: IncompleteCardBuilder(missing: "phoneNumber")),
//            title: try title.unwrap(elseThrow: IncompleteCardBuilder(missing: "title")),
//            address: try address.unwrap(elseThrow: IncompleteCardBuilder(missing: "address"))
//        )
//    }
//}

struct IncompleteCardBuilder: LocalizedError {
    let missing: String
    
    var localizedDescription: String {
        return "Card Builder does not yet have all values necesary to build. Missing \(missing)"
    }
}
