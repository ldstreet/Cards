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
        
        switch indexPath.section {
        case 0:
            
            guard indexPath.row != card.names.count else {
                return makeAddCell(sectionType: "Add Name")
            }
            
            let cell = tableView.dequeueReusableCell(at: indexPath, as: SimpleFieldCell.self)
            cell.configure(with: card.names[indexPath.row], as: .name) {
                guard self.card.names.indices.contains(indexPath.row) else { return }
                self.card.names.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .bottom)
            }
            return cell
        case 1:
            
            guard indexPath.row != card.titles.count else {
                return makeAddCell(sectionType: "Add Job Title")
            }
            
            let cell = tableView.dequeueReusableCell(at: indexPath, as: SimpleFieldCell.self)
            cell.configure(with: card.titles[indexPath.row], as: .title) {
                guard self.card.titles.indices.contains(indexPath.row) else { return }
                self.card.titles.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .bottom)
            }
            return cell
        case 2:
            
            guard indexPath.row != card.emailAddresses.count else {
                return makeAddCell(sectionType: "Add Email Address")
            }
            
            let cell = tableView.dequeueReusableCell(at: indexPath, as: FieldCell<EmailType>.self)
            let emailAddress = card.emailAddresses[indexPath.row]
            cell.configure(as: .email, with: emailAddress.type, value: emailAddress.value, removeAction: {
                guard self.card.emailAddresses.indices.contains(indexPath.row) else { return }
                self.card.emailAddresses.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .bottom)
            }, onUpdate: { typePair in
                self.card.emailAddresses[indexPath.row] = typePair
                self.tableView.reloadData()
            })
            return cell
        case 3:
            
            guard indexPath.row != card.phoneNumbers.count else {
                return makeAddCell(sectionType: "Add Phone Number")
            }
            
            let cell = tableView.dequeueReusableCell(at: indexPath, as: FieldCell<PhoneType>.self)
            let phoneNumber = card.phoneNumbers[indexPath.row]
            cell.configure(as: .phone, with: phoneNumber.type, value: phoneNumber.value, removeAction: {
                guard self.card.phoneNumbers.indices.contains(indexPath.row) else { return }
                self.card.phoneNumbers.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .bottom)
            }, onUpdate: { typePair in
                self.card.phoneNumbers[indexPath.row] = typePair
                self.tableView.reloadData()
            })
            return cell
        case 4:
            
            guard indexPath.row != card.addresses.count else {
                return makeAddCell(sectionType: "Add Address")
            }
            
            let cell = tableView.dequeueReusableCell(at: indexPath, as: FieldCell<AddressType>.self)
            let address = card.addresses[indexPath.row]
            cell.configure(as: .address, with: address.type, value: address.value, removeAction: {
                guard self.card.addresses.indices.contains(indexPath.row) else { return }
                self.card.addresses.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .bottom)
            }, onUpdate: { typePair in
                self.card.addresses[indexPath.row] = typePair
                self.tableView.reloadData()
            })
                
            return cell
        default: return .init()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    private func getCount(ofItemsIn section: Int) -> Int {
        switch section {
        case 0: return card.names.count
        case 1: return card.titles.count
        case 2: return card.emailAddresses.count
        case 3: return card.phoneNumbers.count
        case 4: return card.addresses.count
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getCount(ofItemsIn: section) + 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard indexPath.row == getCount(ofItemsIn: indexPath.section) else { return }
        
        switch indexPath.section {
        case 0: card.names.append("")
        case 1: card.titles.append("")
        case 2: card.emailAddresses.append(.init(.work, ""))
        case 3: card.phoneNumbers.append(.init(.cell, ""))
        case 4: card.addresses.append(.init(.work, ""))
        default: return
        }
        
        tableView.insertRows(at: [indexPath], with: .bottom)
        tableView.reloadRows(at: [indexPath], with: .bottom)
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Names"
        case 1: return "Titles"
        case 2: return "Email Addresses"
        case 3: return "Phone Numbers"
        case 4: return "Addresses"
        default: return ""
        }
    }
}

public enum FieldType {
    case name, title, email, phone, address
}

extension UITextField {
    func configure(as fieldType: FieldType) {
        
        self.borderStyle = .roundedRect
        
        switch fieldType {
        case .name:
            self.textContentType = .name
            self.placeholder = "Name"
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

