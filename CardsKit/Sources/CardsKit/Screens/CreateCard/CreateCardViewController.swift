//
//  CreateCardViewController.swift
//  CardsKit
//
//  Created by Luke Street on 2/9/19.
//

#if os(iOS)
import UIKit

class CreateCardViewController: UIViewController {
    
    private let completion: (Card) -> Void
    
    let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .equalSpacing
        sv.spacing = 10
        sv.alignment = UIStackView.Alignment.fill
        
        return sv
    }()
    
    private lazy var firstNameTextField: UITextField = {
        let textField = self.makeTextField(placeholderText: "First Name")
        textField.textContentType = .name
        return textField
    }()
    
    private lazy var lastNameTextField: UITextField = {
        let textField = self.makeTextField(placeholderText: "Last Name")
        textField.textContentType = .name
        return textField
    }()
    private lazy var titleTextField: UITextField = {
        let textField = self.makeTextField(placeholderText: "Title")
        textField.textContentType = .jobTitle
        return textField
    }()
    private lazy var emailTextField: UITextField = {
        let textField = self.makeTextField(placeholderText: "Email Address")
        textField.textContentType = .emailAddress
        textField.keyboardType = .emailAddress
        return textField
    }()
    private lazy var phoneTextField: UITextField = {
        let textField = self.makeTextField(placeholderText: "Phone Number")
        textField.textContentType = .telephoneNumber
        textField.keyboardType = .phonePad
        return textField
    }()
    private lazy var addressTextField: UITextField = {
        let textField = self.makeTextField(placeholderText: "Address")
        textField.textContentType = .fullStreetAddress
        textField.keyboardType = .default
        return textField
    }()
    
    init(completion: @escaping (Card) -> Void) {
        self.completion = completion
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
        
        stackView.addArrangedSubviews([
            firstNameTextField,
            lastNameTextField,
            titleTextField,
            emailTextField,
            phoneTextField,
            addressTextField
            ])
        view.addSubview(stackView)
        stackView.pin(.horizontal + [.top], to: view, offsetBy: 10)
        
        navigationItem.title = "New Card"
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(tappedDoneButton))
    }
    
    @objc
    private func tappedDoneButton() {
        let card = Card(
            firstName: firstNameTextField.text ?? "",
            lastName: lastNameTextField.text ?? "",
            emailAddress: emailTextField.text ?? "",
            phoneNumber: phoneTextField.text ?? "",
            title: titleTextField.text ?? "",
            address: addressTextField.text ?? ""
        )
        completion(card)
        navigationController?.popViewController(animated: true)
    }
}
#endif
