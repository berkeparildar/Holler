//
//  SignUpViewController.swift
//  Holler
//
//  Created by Berke Parıldar on 13.05.2024.
//

import UIKit

class SignUpViewController: UIViewController, LoadingShowable, MessageShowable {
    
    var viewModel: SignUpViewModel!
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        return view
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "email"
        textField.borderStyle = .none
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "password"
        textField.borderStyle = .none
        textField.textContentType = .oneTimeCode
        textField.isSecureTextEntry = true
        textField.autocorrectionType = .no
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "name"
        textField.borderStyle = .none
        textField.autocorrectionType = .no
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let usernameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "username"
        textField.borderStyle = .none
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    lazy var signUpButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.backgroundColor = .white
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private func createSeparatorView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .gray
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        self.title = "Sign Up"
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.prefersLargeTitles = false
        setupViews()
        hideKeyboardWhenTappedAround()
        usernameTextField.delegate = self
    }
    
    private func setupViews() {
        view.addSubview(backgroundView)
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        view.addSubview(emailTextField)
        NSLayoutConstraint.activate([
            emailTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        let emailSeparator = createSeparatorView()
        view.addSubview(emailSeparator)
        NSLayoutConstraint.activate([
            emailSeparator.topAnchor.constraint(equalTo: emailTextField.bottomAnchor),
            emailSeparator.widthAnchor.constraint(equalTo: emailTextField.widthAnchor),
            emailSeparator.centerXAnchor.constraint(equalTo: emailTextField.centerXAnchor),
            emailSeparator.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        view.addSubview(passwordTextField)
        NSLayoutConstraint.activate([
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        let passwordSeparator = createSeparatorView()
        view.addSubview(passwordSeparator)
        NSLayoutConstraint.activate([
            passwordSeparator.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor),
            passwordSeparator.widthAnchor.constraint(equalTo: passwordTextField.widthAnchor),
            passwordSeparator.centerXAnchor.constraint(equalTo: passwordTextField.centerXAnchor),
            passwordSeparator.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        view.addSubview(nameTextField)
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nameTextField.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        let nameSeparator = createSeparatorView()
        view.addSubview(nameSeparator)
        NSLayoutConstraint.activate([
            nameSeparator.topAnchor.constraint(equalTo: nameTextField.bottomAnchor),
            nameSeparator.widthAnchor.constraint(equalTo: nameTextField.widthAnchor),
            nameSeparator.centerXAnchor.constraint(equalTo: nameTextField.centerXAnchor),
            nameSeparator.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        view.addSubview(usernameTextField)
        NSLayoutConstraint.activate([
            usernameTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20),
            usernameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            usernameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            usernameTextField.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        let usernameSeparator = createSeparatorView()
        view.addSubview(usernameSeparator)
        NSLayoutConstraint.activate([
            usernameSeparator.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor),
            usernameSeparator.widthAnchor.constraint(equalTo: usernameTextField.widthAnchor),
            usernameSeparator.centerXAnchor.constraint(equalTo: usernameTextField.centerXAnchor),
            usernameSeparator.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        view.addSubview(signUpButton)
        NSLayoutConstraint.activate([
            signUpButton.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 20),
            signUpButton.trailingAnchor.constraint(equalTo: usernameTextField.trailingAnchor),
            signUpButton.widthAnchor.constraint(equalToConstant: 64),
            signUpButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    @objc private func signUpButtonTapped() {
        showLoading()
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text, let username = usernameTextField.text else {
            return
        }
        viewModel.signUp(email: email, password: password, name: name, username: username) { [weak self] error in
            guard let self = self else { return }
            hideLoading()
            if let error = error {
                print("Signup error: \(error.localizedDescription)")
            } else {
                print("Signup successful!")
                showMessage(title: "Signup successful!") {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
    }
}

extension SignUpViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == usernameTextField {
            let lowercaseString = string.lowercased()
            if string != lowercaseString {
                textField.text = (textField.text as NSString?)?.replacingCharacters(in: range, with: lowercaseString)
                return false
            }
        }
        return true
    }
}

