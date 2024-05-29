//
//  UserService.swift
//  Holler
//
//  Created by Berke Parıldar on 19.05.2024.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import KeychainAccess

class UserService {
    static let shared = UserService()
    
    var currentUser: User?
    
    private let keychain = Keychain(service: "com.bprldr.Holler")
    private let db = Firestore.firestore()
    
    private init() {}
    
    func fetchCurrentUser(completion: @escaping (User?, Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(nil, NSError(domain: "UserService", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        
        let userRef = db.collection("users").document(uid)
        userRef.getDocument { (document, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let document = document, document.exists, let data = document.data() else {
                completion(nil, NSError(domain: "UserService", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"]))
                return
            }
            
            let user = User(uid: uid, data: data)
            self.currentUser = user
            completion(user, nil)
        }
    }
    
    func saveCurrentUserToKeychain() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            try keychain.set(uid, key: "uid")
        } catch {
            print("Keychain error: \(error.localizedDescription)")
        }
    }
    
    func loadCurrentUserFromKeychain(completion: @escaping (User?, Error?) -> Void) {
        guard let uid = try? keychain.get("uid") else {
            completion(nil, NSError(domain: "UserService", code: 404, userInfo: [NSLocalizedDescriptionKey: "UID not found in keychain"]))
            return
        }
        
        let userRef = db.collection("users").document(uid)
        userRef.getDocument { (document, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let document = document, document.exists, let data = document.data() else {
                completion(nil, NSError(domain: "UserService", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"]))
                return
            }
            
            let user = User(uid: uid, data: data)
            self.currentUser = user
            completion(user, nil)
        }
    }
}
