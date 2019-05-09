//
//  LoginViewController.swift
//  LDSiOSKit
//
//  Created by Luke Street on 2/15/19.
//

#if os(iOS)
import UIKit
import LDSiOSKit

enum TextFieldValidationError: Error {
    case noValue
}
extension UITextField {
    func validated(validator: (String) throws -> Void) throws -> String {
        guard let text = text else { throw TextFieldValidationError.noValue }
        try validator(text)
        return text
    }
}

extension String {
    public var base64Encoded: String? {
        return self.data(using: .utf8)?.base64EncodedString()
    }
}

public class LoginViewController<Environment: LDSiOSKit.EnvironmentProvider>: UIViewController {
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    
    private let emailTextfield: UITextField = {
        let textField = UITextField()
        textField.textContentType = .username
        textField.borderStyle = .bezel
        return textField
    }()
    
    private let passwordTextfield: UITextField = {
        let textField = UITextField()
        textField.clearsOnInsertion = true
        textField.textContentType = .password
        textField.borderStyle = .bezel
        return textField
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.roundedRect)
        button.setTitle("Login", for: .normal)
        button.addTarget(self, action: #selector(tappedLoginButton), for: .touchUpInside)
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
        
        stackView.addArrangedSubviews([
            emailTextfield,
            passwordTextfield,
            loginButton
        ])
        view.addSubview(stackView)
        stackView.center(.horizontallyAndVertically, in: view)
    }
    
    @objc
    private func tappedLoginButton() {
        guard
            let loginData = try? (
                email:
                emailTextfield.validated { email in
                    
                },
                password:
                passwordTextfield.validated { password in
                    
                }
            ), let authStr = "\(loginData.email):\(loginData.password)".base64Encoded
        else {
            return
        }
        
        let request = Request<Environment, UserToken>(
            using: environment,
            path: "login",
            method: .post(body: ["Authorization": "Basic \(authStr)"]))
        request.send { result in
            do {
                let token = try result.get()
                self.completion(.success(token))
            } catch {
                self.completion(.failure(error))
            }
        }
    }
    
}
#endif
