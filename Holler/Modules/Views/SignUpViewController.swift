//
//  SignUpViewController.swift
//  Holler
//
//  Created by Berke Parıldar on 13.05.2024.
//

import UIKit

class SignUpViewController: UIViewController, LoadingShowable, SuccessShowable {
    
    var viewModel: SignUpViewModel!
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "email"
        textField.borderStyle = .none
        textField.autocapitalizationType = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "password"
        textField.borderStyle = .none
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "name"
        textField.borderStyle = .none
        textField.autocapitalizationType = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let usernameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "username"
        textField.borderStyle = .none
        textField.isSecureTextEntry = true
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
    
    private let emailSeperator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .gray
        return view
    }()
    
    private let passwordSeperator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .gray
        return view
    }()
    
    private let nameSeperator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .gray
        return view
    }()
    
    private let usernameSeperator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .gray
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        self.title = "Sign Up"
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.prefersLargeTitles = false
        setupViews()
    }
    
    private func setupViews() {
        // Add email text field
        view.addSubview(emailTextField)
        NSLayoutConstraint.activate([
            emailTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        view.addSubview(emailSeperator)
        NSLayoutConstraint.activate([
            emailSeperator.topAnchor.constraint(equalTo: emailTextField.bottomAnchor),
            emailSeperator.widthAnchor.constraint(equalTo: emailTextField.widthAnchor),
            emailSeperator.centerXAnchor.constraint(equalTo: emailTextField.centerXAnchor),
            emailSeperator.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        // Add password text field
        view.addSubview(passwordTextField)
        NSLayoutConstraint.activate([
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        view.addSubview(passwordSeperator)
        NSLayoutConstraint.activate([
            passwordSeperator.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor),
            passwordSeperator.widthAnchor.constraint(equalTo: passwordTextField.widthAnchor),
            passwordSeperator.centerXAnchor.constraint(equalTo: passwordTextField.centerXAnchor),
            passwordSeperator.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        view.addSubview(nameTextField)
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nameTextField.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        view.addSubview(nameSeperator)
        NSLayoutConstraint.activate([
            nameSeperator.topAnchor.constraint(equalTo: nameTextField.bottomAnchor),
            nameSeperator.widthAnchor.constraint(equalTo: nameTextField.widthAnchor),
            nameSeperator.centerXAnchor.constraint(equalTo: nameTextField.centerXAnchor),
            nameSeperator.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        view.addSubview(usernameTextField)
        NSLayoutConstraint.activate([
            usernameTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20),
            usernameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            usernameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            usernameTextField.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        view.addSubview(usernameSeperator)
        NSLayoutConstraint.activate([
            usernameSeperator.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor),
            usernameSeperator.widthAnchor.constraint(equalTo: usernameTextField.widthAnchor),
            usernameSeperator.centerXAnchor.constraint(equalTo: usernameTextField.centerXAnchor),
            usernameSeperator.heightAnchor.constraint(equalToConstant: 1)
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
                showSuccessMessage {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
    }
}
