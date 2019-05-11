//
//  CreateCardViewController.swift
//  CardsKit
//
//  Created by Luke Street on 2/9/19.
//

#if os(iOS)
import UIKit
import LDSiOSKit

extension UIImage {
    convenience init?(fromCurrentBundleNamed name: String) {
        self.init(named: name, in: Bundle(for: CardsViewController.self), compatibleWith: nil)
    }
}

internal class CreateCardViewController: UITableViewController {
    
    private let completion: (Card) -> Void
    private var card: Card
    
    init(card: Card = .init(), completion: @escaping (Card) -> Void) {
        self.completion = completion
        self.card = card
        super.init(nibName: nil, bundle: nil)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeTextField(placeholderText: String) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholderText
        textField.borderStyle = .roundedRect
        return textField
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        tableView.clipsToBounds = true
        
        tableView.registerReusableCell(AddFieldCell.self)
        tableView.registerReusableCell(SimpleFieldCell.self)
        tableView.registerReusableCell(FieldCell<AddressType>.self)
        tableView.registerReusableCell(FieldCell<PhoneType>.self)
        tableView.registerReusableCell(FieldCell<EmailType>.self)
        
        navigationItem.title = "New Card"
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(tappedDoneButton))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @objc
    private func tappedDoneButton() {
        completion(card)
        navigationController?.popToRootViewController(animated: true)
    }
}

extension CreateCardViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 22
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        func makeAddCell(sectionType: String) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(at: indexPath, as: AddFieldCell.self)
            cell.configure(sectionType: sectionType)
            return cell
        }
        
        func makeSimpleCell(for keypath: WritableKeyPath<Card, [String]>) -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCell(at: indexPath, as: SimpleFieldCell.self)
            cell.configure(with: card[keyPath: keypath][indexPath.row], as: .name) {
                guard self.card[keyPath: keypath].indices.contains(indexPath.row) else { return }
                self.card[keyPath: keypath].remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .bottom)
            }
            return cell
        }
        
        func makeTypedCell<Type: DataType>(for keypath: WritableKeyPath<Card, [TypePair<Type, String>]>) -> UITableViewCell where Type.RawValue == String {
            
            let cell = tableView.dequeueReusableCell(at: indexPath, as: FieldCell<Type>.self)
            let field = card[keyPath: keypath][indexPath.row]
            cell.configure(as: Type.fieldType, with: field.type, value: field.value, removeAction: {
                guard self.card[keyPath: keypath].indices.contains(indexPath.row) else { return }
                self.card[keyPath: keypath].remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .bottom)
            }, onUpdate: { typePair in
                self.card[keyPath: keypath][indexPath.row] = typePair
                self.tableView.reloadData()
            })
            return cell
        }
        
        guard let fieldType = Card.FieldType(rawValue: indexPath.section) else {
            fatalError("\(indexPath.section) is not a valid section.")
        }
        
        switch fieldType {
        case .name:
            guard indexPath.row != card.names.count else {
                return makeAddCell(sectionType: "Add Name")
            }
            return makeSimpleCell(for: \.names)
        case .title:
            
            guard indexPath.row != card.titles.count else {
                return makeAddCell(sectionType: "Add Job Title")
            }
            return makeSimpleCell(for: \.titles)
        case .certificate:
            guard indexPath.row != card.certificates.count else {
                return makeAddCell(sectionType: "Add Certificate")
            }
            return makeSimpleCell(for: \.certificates)
        case .email:
            
            guard indexPath.row != card.emailAddresses.count else {
                return makeAddCell(sectionType: "Add Email Address")
            }
            
            return makeTypedCell(for: \.emailAddresses)
            
        case .phone:
            
            guard indexPath.row != card.phoneNumbers.count else {
                return makeAddCell(sectionType: "Add Phone Number")
            }
            
            return makeTypedCell(for: \.phoneNumbers)
        case .address:
            
            guard indexPath.row != card.addresses.count else {
                return makeAddCell(sectionType: "Add Address")
            }
            
            return makeTypedCell(for: \.addresses)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Card.FieldType.allCases.count
    }
    
    private func getCount(ofItemsIn section: Int) -> Int {
        guard let fieldType = Card.FieldType(rawValue: section) else { return 0 }
        switch fieldType {
        case .name: return card.names.count
        case .title: return card.titles.count
        case .certificate: return card.certificates.count
        case .email: return card.emailAddresses.count
        case .phone: return card.phoneNumbers.count
        case .address: return card.addresses.count
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getCount(ofItemsIn: section) + 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let fieldType = Card.FieldType(rawValue: indexPath.section) else { return }
        guard indexPath.row == getCount(ofItemsIn: indexPath.section) else { return }
        
        switch fieldType {
        case .name: card.names.append("")
        case .title: card.titles.append("")
        case .certificate: card.certificates.append("")
        case .email: card.emailAddresses.append(.init(.work, ""))
        case .phone: card.phoneNumbers.append(.init(.cell, ""))
        case .address: card.addresses.append(.init(.work, ""))
        }
        
        tableView.insertRows(at: [indexPath], with: .bottom)
        tableView.reloadRows(at: [indexPath], with: .bottom)
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let fieldType = Card.FieldType(rawValue: section) else { return nil }
        switch fieldType {
        case .name: return "Names"
        case .title: return "Titles"
        case .certificate: return "Certificates"
        case .email: return "Email Addresses"
        case .phone: return "Phone Numbers"
        case .address: return "Addresses"
        }
    }
}



extension UITextField {
    func configure(as fieldType: Card.FieldType) {
        
        self.borderStyle = .roundedRect
        
        switch fieldType {
        case .name:
            self.textContentType = .name
            self.placeholder = "Name"
        case .certificate:
            self.placeholder = "Certificate"
        case .title:
            self.textContentType = .jobTitle
            self.placeholder = "Job Title"
        case .email:
            self.textContentType = .emailAddress
            self.keyboardType = .emailAddress
            self.placeholder = "Email Address"
        case .phone:
            self.textContentType = .telephoneNumber
            self.keyboardType = .phonePad
            self.placeholder = "Phone Number"
        case .address:
            self.textContentType = .fullStreetAddress
            self.keyboardType = .default
            self.placeholder = "Address"
        }
    }
}


#endif

