//
//  PostCreateViewModel.swift
//  Holler
//
//  Created by Berke Parıldar on 29.05.2024.
//

import Foundation
import UIKit
import FirebaseStorage
import FirebaseFirestore

final class PostCreateViewModel {
    let db = Firestore.firestore()
    let storage = Storage.storage()
    weak var delegate: PostCreationDelegate?
    
    func createPost(text: String, imageData: Data?, completion: @escaping (Bool, Error?) -> Void) {
        guard let currentUserUID = UserService.shared.currentUser?.uid else {
            completion(false, NSError(domain: "User not logged in", code: 401, userInfo: nil))
            return
        }
        
        var postData: [String: Any] = [
            "hasImage": false,
            "image": "",
            "likeCount": 0,
            "likes": [],
            "replies": [],
            "replyCount": 0,
            "text": text,
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
                    postData["image"] = imageUrl
                }
                self.savePostData(postData, postRef: postRef, userID: currentUserUID, completion: completion)
            }
        } else {
            savePostData(postData, postRef: postRef, userID: currentUserUID, completion: completion)
        }
    }
    
    private func uploadImage(_ imageData: Data?, postID: String, completion: @escaping (String?, Error?) -> Void) {
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
            completion("posts/\(postID).jpg", nil)
        }
    }
    
    private func savePostData(_ postData: [String: Any], postRef: DocumentReference, userID: String, completion: @escaping (Bool, Error?) -> Void) {
        postRef.setData(postData) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                completion(false, error)
                return
            }
            self.addPostToUser(postID: postRef.documentID, userID: userID, completion: completion)
            self.delegate?.didPost()
        }
    }
    
    private func addPostToUser(postID: String, userID: String, completion: @escaping (Bool, Error?) -> Void) {
        let userRef = db.collection("users").document(userID)
        var currentPosts = UserService.shared.currentUser?.posts
        currentPosts?.append(postID)
        userRef.updateData(["posts": currentPosts!]) { error in
            if let error = error {
                completion(false, error)
                return
            }
            completion(true, nil)
        }
    }
}
