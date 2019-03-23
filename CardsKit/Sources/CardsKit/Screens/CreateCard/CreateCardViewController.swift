//
//  CreateCardViewController.swift
//  CardsKit
//
//  Created by Luke Street on 2/9/19.
//

#if os(iOS)
import UIKit
import LDSiOSKit

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
        
        tableView.estimatedRowHeight = 22
        tableView.rowHeight = UITableView.automaticDimension
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @objc
    private func tappedDoneButton() {
        completion(card)
        navigationController?.popToRootViewController(animated: true)
    }
}

extension CreateCardViewController {
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
            cell.configure(as: .name, with: card.names[indexPath.row]) {
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
            cell.configure(as: .title, with: card.titles[indexPath.row]) {
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
            cell.configure(as: .email, with: emailAddress.type, value: emailAddress.value) {
                guard self.card.emailAddresses.indices.contains(indexPath.row) else { return }
                self.card.emailAddresses.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .bottom)
            }
            return cell
        case 3:
            
            guard indexPath.row != card.phoneNumbers.count else {
                return makeAddCell(sectionType: "Add Phone Number")
            }
            
            let cell = tableView.dequeueReusableCell(at: indexPath, as: FieldCell<PhoneType>.self)
            let phoneNumber = card.phoneNumbers[indexPath.row]
            cell.configure(as: .phone, with: phoneNumber.type, value: phoneNumber.value) {
                guard self.card.phoneNumbers.indices.contains(indexPath.row) else { return }
                self.card.phoneNumbers.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .bottom)
            }
            return cell
        case 4:
            
            guard indexPath.row != card.addresses.count else {
                return makeAddCell(sectionType: "Add Address")
            }
            
            let cell = tableView.dequeueReusableCell(at: indexPath, as: FieldCell<AddressType>.self)
            let address = card.addresses[indexPath.row]
            cell.configure(as: .address, with: address.type, value: address.value) {
                guard self.card.addresses.indices.contains(indexPath.row) else { return }
                self.card.addresses.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .bottom)
            }
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
        case 2: card.emailAddresses.append(.init(type: .other, value: ""))
        case 3: card.phoneNumbers.append(.init(type: .other, value: ""))
        case 4: card.addresses.append(.init(type: .other, value: ""))
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

private class SimpleFieldCell: UITableViewCell, Reusable {
    
    private var textField = UITextField()
    private var removeButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "remove"), for: .normal)
        return button
    }()
    private var stackView: UIStackView = {
        let sv = UIStackView(frame: .zero)
        sv.axis = .horizontal
        sv.alignment = .center
        return sv
    }()
    
    private var initialLayout = true
    private var types = [String]()
    
    @objc
    private func removeButtonTapped() { removeAction() }
    private var removeAction: () -> () = {}
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if initialLayout {
            
            removeButton.addTarget(self, action: #selector(removeButtonTapped), for: .touchUpInside)
            
            stackView.addArrangedSubviews(
                [
                    removeButton,
                    textField
                ]
            )
            
            removeButton.size(width: 22, height: 22)
            
            contentView.addSubview(stackView)
            stackView.pin(.all, to: contentView)
            
            initialLayout = false
        }
    }
    
    func configure(as type: FieldType, with value: String, removeAction: @escaping () -> ()) {
        textField.text = value
        textField.configure(as: type)
        self.removeAction = removeAction
    }
}

private class AddFieldCell: UITableViewCell, Reusable {
    
    private let addIcon = UIImageView(image: #imageLiteral(resourceName: "add"))
    private let label = UILabel()
    
    private var stackView: UIStackView = {
        let sv = UIStackView(frame: .zero)
        sv.axis = .horizontal
        sv.alignment = .center
        return sv
    }()
    
    private var initialLayout = true
    
    override func layoutSubviews() {
        if initialLayout {
            stackView.addArrangedSubviews(
                [
                    addIcon,
                    label
                ]
            )
            
            addIcon.size(width: 22, height: 22)
            
            contentView.addSubview(stackView)
            stackView.pin(.all, to: contentView)
            
            initialLayout = false
        }
    }
    
    func configure(sectionType: String) {
        label.text = sectionType
    }
}

private class FieldCell<Type: DataType>: UITableViewCell, Reusable, UIPickerViewDataSource, UIPickerViewDelegate where Type.RawValue == String {
    private var textField = UITextField()
    private var removeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "remove"), for: .normal)
        return button
    }()
    private var typeButton: UIButton = {
        let button = UIButton()
//        button.setImage(#imageLiteral(resourceName: "right-caret"), for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.titleLabel?.font = button.titleLabel?.font.withSize(12)
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        button.addTarget(self, action: #selector(typeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private var stackView: UIStackView = {
        let sv = UIStackView(frame: .zero)
        sv.axis = .horizontal
        sv.alignment = .center
        sv.spacing = 10
        return sv
    }()
    
    private lazy var typePicker: UIPickerView = {
        let picker = UIPickerView(frame: .zero)
        
        picker.dataSource = self
        picker.delegate = self
        
        return picker
    }()
    
    @objc
    private func removeButtonTapped() { removeAction() }
    private var removeAction: () -> () = {}
    
    @objc
    private func typeButtonTapped() {
        
    }
    
    private var initialLayout = true
    private var types = [String]()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if initialLayout {
            
            removeButton.addTarget(self, action: #selector(removeButtonTapped), for: .touchUpInside)
            
            
            stackView.addArrangedSubviews(
                [
                    removeButton,
                    typeButton,
                    textField
                ]
            )
            
            removeButton.size(width: 22, height: 22)
            
            contentView.addSubview(stackView)
            stackView.pin(.all, to: contentView)
            
            initialLayout = false
            
        }
        
    }
    
    func configure(as fieldType: FieldType, with valueType: Type, value: String, removeAction: @escaping () -> ()) {
        self.textField.text = value
        self.types = Type.types
        self.typeButton.setTitle(valueType.rawValue, for: .normal)
        self.textField.configure(as: fieldType)
        self.removeAction = removeAction
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return types.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return types[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        typeButton.setTitle(types[row], for: .normal)
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}
#endif
