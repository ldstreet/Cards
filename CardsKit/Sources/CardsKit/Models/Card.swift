import Foundation

public struct Card: Codable {
    public let firstName: String
    public let lastName: String
    public let emailAddress: String
    public let phoneNumber: String
    public let title: String
    public let subTitle: String
    public let address: String
    public let uuid: UUID = .init()
    
    public init(
        firstName: String,
        lastName: String,
        emailAddress: String,
        phoneNumber: String,
        title: String,
        subTitle: String,
        address: String
        )
    {
        self.firstName = firstName
        self.lastName = lastName
        self.emailAddress = emailAddress
        self.phoneNumber = phoneNumber
        self.title = title
        self.subTitle = subTitle
        self.address = address
    }
}
