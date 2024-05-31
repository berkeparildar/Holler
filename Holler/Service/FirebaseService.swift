//
//  FirebaseService.swift
//  Holler
//
//  Created by Berke Parıldar on 30.05.2024.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

final class FirebaseService {
    
    static let shared = FirebaseService()
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    func fetchUser(userID: String, completion: @escaping (User?, Error?) -> Void) {
        let userRef = db.collection("users").document(userID)
        userRef.getDocument { document, error in
            if let error = error {
                completion(nil, error)
            }
            guard let document = document, document.exists, let data = document.data() else {
                return
            }
            let user = User(uid: userID, data: data)
            completion(user, nil)
        }
    }
    
    func fetchPost(postID: String, user: User?, completion: @escaping (Post?, Error?) -> Void) {
        let postRef = db.collection("posts").document(postID)
        postRef.getDocument { document, error in
            if let error = error {
                completion(nil, error)
            }
            guard let document = document, document.exists, let data = document.data() else {
                return
            }
            let post = Post(id: postID, data: data, user: user)
            completion(post, nil)
        }
    }
    
    func getImageURL(from path: String, completion: @escaping (URL?) -> Void) {
        let storageRef = storage.reference().child(path)
        storageRef.downloadURL { (url, error) in
            if let error = error {
                print("Error fetching image URL: \(error.localizedDescription)")
                completion(nil)
                return
            }
            completion(url)
        }
    }
}
