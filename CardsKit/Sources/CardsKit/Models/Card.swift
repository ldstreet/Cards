import Foundation

public struct Card: Codable {
    public let firstName: String
    public let lastName: String
    public let emailAddress: String
    public let phoneNumber: String
    public let title: String
    public let address: String
    public let uuid: UUID = .init()
    
    public init(
        firstName: String,
        lastName: String,
        emailAddress: String,
        phoneNumber: String,
        title: String,
        address: String
        )
    {
        self.firstName = firstName
        self.lastName = lastName
        self.emailAddress = emailAddress
        self.phoneNumber = phoneNumber
        self.title = title
        self.address = address
    }
}

public struct CardBuilder {
    public var firstName: String?
    public var lastName: String?
    public var emailAddress: String?
    public var phoneNumber: String?
    public var title: String?
    public var address: String?
    public var uuid: UUID = .init()
    
    public init(
        firstName: String? = nil,
        lastName: String? = nil,
        emailAddress: String? = nil,
        phoneNumber: String? = nil,
        title: String? = nil,
        address: String? = nil
        )
    {
        self.firstName = firstName
        self.lastName = lastName
        self.emailAddress = emailAddress
        self.phoneNumber = phoneNumber
        self.title = title
        self.address = address
    }
    
    func appending(_ builder: CardBuilder) -> CardBuilder {
        return .init(
            firstName: firstName ?? builder.firstName,
            lastName: lastName ?? builder.lastName,
            emailAddress: emailAddress ?? builder.emailAddress,
            phoneNumber: phoneNumber ?? builder.phoneNumber,
            title: title ?? builder.title,
            address: address ?? builder.address
        )
    }
    
    func build() throws -> Card {
        return .init(
            firstName: try firstName.unwrap(elseThrow: IncompleteCardBuilder(missing: "firstName")),
            lastName: try lastName.unwrap(elseThrow: IncompleteCardBuilder(missing: "lastName")),
            emailAddress: try emailAddress.unwrap(elseThrow: IncompleteCardBuilder(missing: "emailAddress")),
            phoneNumber: try phoneNumber.unwrap(elseThrow: IncompleteCardBuilder(missing: "phoneNumber")),
            title: try title.unwrap(elseThrow: IncompleteCardBuilder(missing: "title")),
            address: try address.unwrap(elseThrow: IncompleteCardBuilder(missing: "address"))
        )
    }
}

struct IncompleteCardBuilder: LocalizedError {
    let missing: String
    
    var localizedDescription: String {
        return "Card Builder does not yet have all values necesary to build. Missing \(missing)"
    }
}
