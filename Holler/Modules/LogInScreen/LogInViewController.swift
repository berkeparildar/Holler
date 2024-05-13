//
//  LogInViewController.swift
//  Holler
//
//  Created by Berke Parıldar on 13.05.2024.
//

import UIKit


class LogInViewController: UIViewController {
    
    var viewModel: LogInViewModel!
    
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
    
    lazy var loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.backgroundColor = .white
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
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
    
    lazy var signupButton: UIButton = {
        let button = UIButton()
        button.setTitle("Dont't have an account? Sign Up", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(signupButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        // Add email text field
        view.addSubview(emailTextField)
        NSLayoutConstraint.activate([
            emailTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
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
        
        view.addSubview(loginButton)
        NSLayoutConstraint.activate([
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            loginButton.trailingAnchor.constraint(equalTo: passwordTextField.trailingAnchor),
            loginButton.widthAnchor.constraint(equalToConstant: 64),
            loginButton.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        // Add signup button
        view.addSubview(signupButton)
        NSLayoutConstraint.activate([
            signupButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            signupButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -20),
            signupButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    @objc private func loginButtonTapped() {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            return
        }
        viewModel.logIn(email: email, password: password)
    }
    
    @objc private func signupButtonTapped() {
        print("Sign Up button tapped!")
    }
}
