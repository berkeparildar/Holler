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
        Auth.auth().createUser(withEmail: email, password: password) {
            (authResult, error) in
            if let error = error {
                completion(error)
                return
            }
            
            // User successfully created in Firebase Authentication
            if let authUser = authResult?.user {
                // Step 2: Create user document in Firestore
                let userData: [String: Any] = [
                    "name": name,
                    "username": username,
                    "followers": [String](),
                    "following": [String](),
                    "posts": [String](),
                    "profileURL": "defaults/defaultImage.jpg",
                    "bannerURL": "defaults/defaultBanner.jpg"
                    // Add other user data as needed
                ]
                
                let db = Firestore.firestore()
                let userRef = db.collection("users").document(authUser.uid)
                
                userRef.setData(userData) { error in
                    if let error = error {
                        // Error creating user document in Firestore
                        completion(error)
                    } else {
                        // User document created successfully in Firestore
                        completion(nil) // No error
                    }
                }
            } else {
                print("Oh god")
                // Unexpected error: authResult.user is nil
                //let unexpectedError = NSError(domain: "com.yourapp.signup", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unexpected error"])
                //completion(unexpectedError)
            }
        }
    }
}
