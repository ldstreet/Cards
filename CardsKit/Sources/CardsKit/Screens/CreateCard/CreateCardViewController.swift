//
//  CreateCardViewController.swift
//  CardsKit
//
//  Created by Luke Street on 2/9/19.
//

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
    
    private lazy var firstNameTextField = makeTextField(placeholderText: "First Name")
    private lazy var lastNameTextField = makeTextField(placeholderText: "Last Name")
    private lazy var titleTextField = makeTextField(placeholderText: "Title")
    private lazy var subTitleTextField = makeTextField(placeholderText: "Subtitle")
    private lazy var emailTextField = makeTextField(placeholderText: "Email Address")
    private lazy var phoneTextField = makeTextField(placeholderText: "Phone Number")
    private lazy var addressTextField = makeTextField(placeholderText: "Address")
    
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
            subTitleTextField,
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
            emailAddress: addressTextField.text ?? "",
            phoneNumber: phoneTextField.text ?? "",
            title: titleTextField.text ?? "",
            subTitle: subTitleTextField.text ?? "",
            address: addressTextField.text ?? ""
        )
        completion(card)
        navigationController?.popViewController(animated: true)
    }
    
    
}
