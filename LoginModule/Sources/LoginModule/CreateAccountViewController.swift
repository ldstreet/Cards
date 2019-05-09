//
//  CreateAccountViewController.swift
//  LoginModule
//
//  Created by Luke Street on 2/17/19.
//

import Foundation

#if os(iOS)
import UIKit
import LDSiOSKit

public class CreateAccountViewController<Environment: EnvironmentProvider>: UIViewController {
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    
    private let nameTextfield: UITextField = {
        let textField = UITextField()
        textField.text = "Luke Street"
        textField.placeholder = "Name"
        textField.textContentType = .name
        textField.borderStyle = .bezel
        return textField
    }()
    
    private let emailTextfield: UITextField = {
        let textField = UITextField()
        textField.text = "ldstreet@me.copm"
        textField.placeholder = "Email Address"
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.keyboardType = .emailAddress
        textField.textContentType = .emailAddress
        textField.borderStyle = .bezel
        return textField
    }()
    
    private let passwordTextfield: UITextField = {
        let textField = UITextField()
        textField.text = "Password1"
        textField.placeholder = "Password"
        textField.clearsOnInsertion = true
        textField.isSecureTextEntry = true
        textField.textContentType = .password
        textField.borderStyle = .bezel
        return textField
    }()
    
    private let verifyPasswordTextfield: UITextField = {
        let textField = UITextField()
        textField.text = "Password1"
        textField.placeholder = "Verify Password"
        textField.clearsOnInsertion = true
        textField.isSecureTextEntry = true
        textField.textContentType = .password
        textField.borderStyle = .bezel
        return textField
    }()
    
    private let registerButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.roundedRect)
        button.setTitle("Register", for: .normal)
        button.addTarget(self, action: #selector(tappedRegisterButton), for: .touchUpInside)
        return button
    }()
    
    private let environment: Environment
    private let completion: ResultClosure<UserToken, Error>
    
    public init(_ environment: Environment, completion: @escaping ResultClosure<UserToken, Error>) {
        self.environment = environment
        self.completion = completion
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        stackView.addArrangedSubviews([
            nameTextfield,
            emailTextfield,
            passwordTextfield,
            verifyPasswordTextfield,
            registerButton
            ])
        view.addSubview(stackView)
        stackView.spacing = 10
        stackView.center(.vertically, in: view)
        stackView.pin(.horizontal, to: view, offsetBy: 50)
    }
    
    struct CreateUserData: Codable {
        /// User's full name.
        var name: String
        
        /// User's email address.
        var email: String
        
        /// User's desired password.
        var password: String
        
        /// User's password repeated to ensure they typed it correctly.
        var verifyPassword: String
    }
    
    @objc
    private func tappedRegisterButton() {
        
        guard
            let createData = try? CreateUserData(
                name: nameTextfield.validated { name in
                    return
                },
                email: emailTextfield.validated { name in
                    return
                },
                password: passwordTextfield.validated { name in
                    return
                },
                verifyPassword: verifyPasswordTextfield.validated { name in
                    return
                }
            ),
            let authStr = "\(createData.email):\(createData.password)".base64Encoded
        else { return }
        
        let createRequest = Request<Environment, UserResponse>(
            using: environment,
            path: "users",
            method: createData.post
        )
        
        createRequest.send { result in
            do {
                let userResponse = try result.get()
                print(userResponse)
                
                let loginRequest = Request<Environment, UserToken>(
                    using: self.environment,
                    path: "login",
                    method: .post(body: [:]),
                    headers: ["Authorization": "Basic \(authStr)"]
                )
                
                loginRequest.send { result in
                    do {
                        let token = try result.get()
                        self.completion(.success(token))
                    } catch {
                        self.completion(.failure(error))
                    }
                }
            } catch {
                self.completion(.failure(error))
            }
        }
    }
    
}


#endif
