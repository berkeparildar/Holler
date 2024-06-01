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
            guard let document = document, document.exists, let data = document.data() else { return }
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
    
    func lookForUser(with userID: String, completion: @escaping ([String]?, Error?) -> Void) {
        db.collection("usernames").getDocuments { querySnapshot, error in
            if let error = error {
                print("There was an error searching users: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            var usernames: [String] = []
            for document in querySnapshot!.documents {
                let documentName = document.documentID
                print(documentName)
                if documentName.contains(userID) {
                    let userID = document.data()["userID"] as! String
                    usernames.append(userID)
                    print(userID)
                }
            }
            completion(usernames.isEmpty ? nil : usernames, nil)
        }
    }
    
    func createPost(text: String, imageData: Data?, completion: @escaping (Bool, Error?) -> Void) {
        guard let currentUserUID = UserService.shared.currentUser?.uid else {
            completion(false, NSError(domain: "User not logged in", code: 401, userInfo: nil))
            return
        }
        var postData: [String: Any] = [
            "hasImage": false,
            "image": "",
            "likes": [],
            "replies": [],
            "text": text,
            "userID": UserService.shared.currentUser!.uid,
            "time": Int(Date().timeIntervalSince1970)
        ]
        let postRef = db.collection("posts").document()
        if let imageData = imageData {
            uploadImage(imageData, postID: postRef.documentID) { imageUrl, error in
                if let error = error {
                    completion(false, error)
                    return
                }
                if let imageUrl = imageUrl {
                    postData["hasImage"] = true
                    postData["image"] = imageUrl.absoluteString
                }
                self.savePostData(postData, postRef: postRef, userID: currentUserUID, completion: completion)
            }
        } else {
            savePostData(postData, postRef: postRef, userID: currentUserUID, completion: completion)
        }
    }
    
    func savePostData(_ postData: [String: Any], postRef: DocumentReference, userID: String, completion: @escaping (Bool, Error?) -> Void) {
        postRef.setData(postData) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                completion(false, error)
                return
            }
            self.addPostToUser(postID: postRef.documentID, userID: userID, completion: completion)
        }
    }
    
    private func addPostToUser(postID: String, userID: String, completion: @escaping (Bool, Error?) -> Void) {
        let userRef = db.collection("users").document(userID)
        UserService.shared.currentUser!.posts.append(postID)
        userRef.updateData(["posts": UserService.shared.currentUser!.posts]) { error in
            if let error = error {
                completion(false, error)
                return
            }
            completion(true, nil)
        }
    }
    
    func uploadImage(_ imageData: Data?, postID: String, completion: @escaping (URL?, Error?) -> Void) {
        guard let imageData = imageData else {
            completion(nil, NSError(domain: "Image conversion error", code: 400, userInfo: nil))
            return
        }
        let storageRef = storage.reference().child("posts/\(postID).jpg")
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                completion(nil, error)
                return
            }
            let imagePath = "posts/\(postID).jpg"
            FirebaseService.shared.getImageURL(from: imagePath) { url in
                completion(url, nil)
            }
        }
    }
}
