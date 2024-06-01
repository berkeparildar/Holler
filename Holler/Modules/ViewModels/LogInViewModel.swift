//
//  LogInViewController.swift
//  Holler
//
//  Created by Berke Parıldar on 13.05.2024.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import KeychainAccess

protocol LogInViewModelDelegate: AnyObject {
    func logInOutput(success: Bool, user: User?)
}

final class LogInViewModel {
    
    weak var delegate: LogInViewModelDelegate?
    
    func logIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (authResult, error) in
            guard let self = self else { return }
            if let error = error {
                print("Login error: \(error.localizedDescription)")
                delegate?.logInOutput(success: false, user: nil)
                return
            }
            UserService.shared.fetchCurrentUser { (user, error) in
                if let error = error {
                    print("Error fetching user: \(error.localizedDescription)")
                    self.delegate?.logInOutput(success: false, user: nil)
                    return
                }
                
                if let user = user {
                    print("User fetched: \(user.name)")
                    UserService.shared.saveCurrentUserToKeychain()
                    self.delegate?.logInOutput(success: true, user: user)
                }
            }
        }
    }
}
