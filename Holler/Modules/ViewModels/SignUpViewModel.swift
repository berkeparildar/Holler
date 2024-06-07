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
                    "profileURL": "https://firebasestorage.googleapis.com/v0/b/holler-623d7.appspot.com/o/defaults%2FdefaultImage.jpg?alt=media&token=2b0ca02b-c426-4fe4-8141-2c25c4e94a9c",
                    "bannerURL": "https://firebasestorage.googleapis.com/v0/b/holler-623d7.appspot.com/o/defaults%2FdefaultBanner.jpg?alt=media&token=810af4cf-828e-4b93-8afc-fb43ed9128ad"
                ]
                let db = Firestore.firestore()
                let usernameRef = db.collection("usernames").document(userData["username"] as! String)
                usernameRef.setData(["userID": authUser.uid])
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
