//
//  LogInViewController.swift
//  Holler
//
//  Created by Berke Parıldar on 13.05.2024.
//

import UIKit
import FirebaseAuth

protocol LogInViewModelDelegate: AnyObject {
    func logInOutput(success: Bool)
}

final class LogInViewModel {
    
    weak var delegate: LogInViewModelDelegate?
    
    func logIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (authResult, error) in
            guard let self = self else { return }
            if let error = error {
                print("Login error: \(error.localizedDescription)")
                delegate?.logInOutput(success: false)
                return
            }
            print("Login successful!")
            delegate?.logInOutput(success: true)
        }
    }
}
