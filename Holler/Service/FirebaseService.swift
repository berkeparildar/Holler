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
                }
            }
            completion(usernames.isEmpty ? nil : usernames, nil)
        }
    }
    
    func createPost(text: String, imageData: Data?, completion: @escaping (String?, Error?) -> Void) {
        guard let currentUserUID = UserService.shared.currentUser?.uid else {
            completion(nil, NSError(domain: "User not logged in", code: 401, userInfo: nil))
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
            uploadPostImage(imageData, postID: postRef.documentID) { imageUrl, error in
                if let error = error {
                    completion(nil, error)
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
    
    func createReply(text: String, imageData: Data?, rootPostID: String, completion: @escaping (String?, Error?) -> Void) {
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
            uploadPostImage(imageData, postID: postRef.documentID) { imageUrl, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                if let imageUrl = imageUrl {
                    postData["hasImage"] = true
                    postData["image"] = imageUrl.absoluteString
                }
                self.saveReplyData(postData, rootPostID: rootPostID, postRef: postRef, completion: completion)
            }
        } else {
            self.saveReplyData(postData, rootPostID: rootPostID, postRef: postRef, completion: completion)
        }
    }
    
    func savePostData(_ postData: [String: Any], postRef: DocumentReference, userID: String, completion: @escaping (String?, Error?) -> Void) {
        postRef.setData(postData) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                completion(nil, error)
                return
            }
            self.addPostToUser(postID: postRef.documentID, userID: userID, completion: completion)
        }
    }
    
    func saveReplyData(_ postData: [String: Any], rootPostID: String, postRef: DocumentReference, completion: @escaping (String?, Error?) -> Void) {
        postRef.setData(postData) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                completion(nil, error)
                return
            }
            addReplyToPost(postID: postRef.documentID, rootPostID: rootPostID, completion: completion)
        }
    }
    
    private func addPostToUser(postID: String, userID: String, completion: @escaping (String?, Error?) -> Void) {
        let userRef = db.collection("users").document(userID)
        UserService.shared.currentUser!.posts.append(postID)
        userRef.updateData(["posts": UserService.shared.currentUser!.posts]) { error in
            if let error = error {
                completion(nil, error)
                return
            }
            completion(postID, nil)
        }
    }
    
    private func addReplyToPost(postID: String, rootPostID: String, completion: @escaping (String?, Error?) -> Void) {
        let postRef = db.collection("posts").document(rootPostID)
        postRef.updateData(["replies": FieldValue.arrayUnion([postID])]) { error in
            if let error = error {
                completion(nil, error)
                return
            }
            completion(postID, nil)
        }
    }
    
    func followUser(targetUserID: String, currentUserID: String, completion: @escaping (Error?) -> Void) {
        UserService.shared.currentUser!.following.append(targetUserID)
        let userRef = db.collection("users")
        let targetUserRef = userRef.document(targetUserID)
        let currentUserRef = userRef.document(currentUserID)
        let batch = db.batch()
        batch.updateData([
            "followers": FieldValue.arrayUnion([currentUserID])
        ], forDocument: targetUserRef)
        
        batch.updateData([
            "following": FieldValue.arrayUnion([targetUserID])
        ], forDocument: currentUserRef)
        batch.commit { error in
            completion(error)
        }
    }
    
    func unfollowUser(targetUserID: String, currentUserID: String, completion: @escaping (Error?) -> Void) {
        let index = UserService.shared.currentUser!.following.firstIndex { userID in
            userID == targetUserID
        }
        UserService.shared.currentUser!.following.remove(at: index!)
        let userRef = db.collection("users")
        let targetUserRef = userRef.document(targetUserID)
        let currentUserRef = userRef.document(currentUserID)
        let batch = db.batch()
        batch.updateData([
            "followers": FieldValue.arrayRemove([currentUserID])
        ], forDocument: targetUserRef)
        batch.updateData([
            "following": FieldValue.arrayRemove([targetUserID])
        ], forDocument: currentUserRef)
        batch.commit { error in
            completion(error)
        }
    }
    
    func likePost(postID: String, completion: @escaping (Error?) -> Void) {
        let postRef = db.collection("posts").document(postID)
        postRef.updateData([
            "likes": FieldValue.arrayUnion([UserService.shared.currentUser!.uid])
        ]) { error in
            completion(error)
        }
    }
    
    func unlikePost(postID: String, completion: @escaping (Error?) -> Void) {
        let postRef = db.collection("posts").document(postID)
        postRef.updateData([
            "likes": FieldValue.arrayRemove([UserService.shared.currentUser!.uid])
        ]) { error in
            completion(error)
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
    
    func uploadPostImage(_ imageData: Data?, postID: String, completion: @escaping (URL?, Error?) -> Void) {
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
    
    func uploadUserProfileImage(_ imageData: Data?, completion: @escaping (Error?) -> Void) {
        guard let imageData = imageData else {
            completion(NSError(domain: "Image conversion error", code: 400, userInfo: nil))
            return
        }
        guard let currentUser = UserService.shared.currentUser else { return }
        let storageRef = storage.reference().child("profileImages/\(currentUser.uid).jpg")
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                completion(error)
                return
            }
            let imagePath = "profileImages/\(currentUser.uid).jpg"
            FirebaseService.shared.getImageURL(from: imagePath) { [weak self] url in
                guard let self = self, let url = url else { return }
                let userRef = db.collection("users").document(currentUser.uid)
                UserService.shared.currentUser!.profileImageURL = url.absoluteString
                userRef.updateData(["profileURL": url.absoluteString])
                completion(nil)
            }
        }
    }
    
    func uploadUserBannerImage(_ imageData: Data?, completion: @escaping (Error?) -> Void) {
        guard let imageData = imageData else {
            completion(NSError(domain: "Image conversion error", code: 400, userInfo: nil))
            return
        }
        guard let currentUser = UserService.shared.currentUser else { return }
        let storageRef = storage.reference().child("bannerImages/\(currentUser.uid).jpg")
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                completion(error)
                return
            }
            let imagePath = "bannerImages/\(currentUser.uid).jpg"
            FirebaseService.shared.getImageURL(from: imagePath) { [weak self] url in
                guard let self = self, let url = url else { return }
                let userRef = db.collection("users").document(currentUser.uid)
                UserService.shared.currentUser!.bannerImageURL = url.absoluteString
                userRef.updateData(["bannerURL": url.absoluteString])
                completion(nil)
            }
        }
    }
}
