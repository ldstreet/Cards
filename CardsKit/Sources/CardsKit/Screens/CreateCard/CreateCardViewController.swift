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
        textField.text = cardBuilder.firstName
        return textField
    }()
    
    private lazy var lastNameTextField: UITextField = {
        let textField = self.makeTextField(placeholderText: "Last Name")
        textField.textContentType = .name
        textField.text = cardBuilder.lastName
        return textField
    }()
    
    private lazy var titleTextField: UITextField = {
        let textField = self.makeTextField(placeholderText: "Title")
        textField.textContentType = .jobTitle
        textField.text = cardBuilder.title
        return textField
    }()
    
    private lazy var emailTextField: UITextField = {
        let textField = self.makeTextField(placeholderText: "Email Address")
        textField.textContentType = .emailAddress
        textField.keyboardType = .emailAddress
        textField.text = cardBuilder.emailAddress
        return textField
    }()
    
    private lazy var phoneTextField: UITextField = {
        let textField = self.makeTextField(placeholderText: "Phone Number")
        textField.textContentType = .telephoneNumber
        textField.keyboardType = .phonePad
        textField.text = cardBuilder.phoneNumber
        return textField
    }()
    
    private lazy var addressTextField: UITextField = {
        let textField = self.makeTextField(placeholderText: "Address")
        textField.textContentType = .fullStreetAddress
        textField.keyboardType = .default
        textField.text = cardBuilder.address
        return textField
    }()
    
    private var cardBuilder: CardBuilder
    
    
    init(cardBuilder: CardBuilder = .init(), completion: @escaping (Card) -> Void) {
        self.completion = completion
        self.cardBuilder = cardBuilder
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        switch textField {
            case firstNameTextField: cardBuilder.firstName = textField.text
            case lastNameTextField: cardBuilder.lastName = textField.text
            case titleTextField: cardBuilder.title = textField.text
            case emailTextField: cardBuilder.emailAddress = textField.text
            case phoneTextField: cardBuilder.phoneNumber = textField.text
            case addressTextField: cardBuilder.address = textField.text
            default: break
        }
    }
    
    private func makeTextField(placeholderText: String) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholderText
        textField.borderStyle = .roundedRect
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @objc
    private func tappedDoneButton() {
        do {
            completion(try cardBuilder.build())
            navigationController?.popToRootViewController(animated: true)
        } catch {
            let errorAlert = UIAlertController(title: "Missing Fields", message: "Not all require fields have been filled out.", preferredStyle: .alert)
            errorAlert.addAction(
                .init(
                    title: "Continue",
                    style: .default
                )
                { _ in
                    errorAlert.dismiss(animated: true, completion: nil)
                }
            )
            
            errorAlert.addAction(
                .init(
                    title: "Cancel",
                    style: .destructive
                    )
                { _ in
                    self.navigationController?.popViewController(animated: true)
                }
            )
            present(errorAlert, animated: true, completion: nil)
        }
    }
}
#endif
