//
//  SignUpViewModel.swift
//  Holler
//
//  Created by Berke Parıldar on 13.05.2024.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

final class SignUpViewModel {
        
    func signUp(email: String, password: String, name: String, username: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            if let error = error {
                completion(error)
                return
            }
            if let authUser = authResult?.user {
                let userData: [String: Any] = [
                    "name": name,
                    "username": username,
                    "followers": [String](),
                    "following": [String](),
                    "posts": [String](),
                    "profileURL": "defaults/defaultImage.jpg",
                    "bannerURL": "defaults/defaultBanner.jpg"
                ]
                
                let db = Firestore.firestore()
                let userRef = db.collection("users").document(authUser.uid)
                
                userRef.setData(userData) { error in
                    if let error = error {
                        completion(error)
                    } else {
                        completion(nil)
                    }
                }
            } 
        }
    }
}
