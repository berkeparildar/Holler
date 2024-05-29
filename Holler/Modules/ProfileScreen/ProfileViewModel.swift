//
//  ProfileViewModel.swift
//  Holler
//
//  Created by Berke Parıldar on 20.05.2024.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

protocol ProfileDelegate: AnyObject {
    func fetchPostOutput(posts: [ProfilePost])
}

final class ProfileViewModel {
    let userID: String
    weak var delegate: ProfileDelegate?
    
    init(userID: String) {
        self.userID = userID
    }
    
    func fetchUser(completion: @escaping (User?, Error?) -> Void) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userID)
        
        userRef.getDocument { (document, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let document = document, document.exists, let data = document.data() else {
                completion(nil, NSError(domain: "ProfileViewModel", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"]))
                return
            }
            
            let user = User(uid: self.userID, data: data)
            completion(user, nil)
        }
    }
    
    func fetchPosts(with postIDs: [String]) {
        let db = Firestore.firestore()
        let postsRef = db.collection("posts")
        var fetchedPosts: [ProfilePost] = []
        let dispatchGroup = DispatchGroup()
        for postID in postIDs {
            dispatchGroup.enter()
            postsRef.document(postID).getDocument { (document, error) in
                if let error = error {
                    print("Error fetching post: \(error.localizedDescription)")
                    dispatchGroup.leave()
                    return
                }
                
                guard let document = document, document.exists, let data = document.data() else {
                    dispatchGroup.leave()
                    return
                }
                
                let post = ProfilePost(id: postID, data: data)
                fetchedPosts.append(post)
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.delegate?.fetchPostOutput(posts: fetchedPosts)
        }
    }
    
    func loadImage(from path: String, completion: @escaping (URL?) -> Void) {
            let storage = Storage.storage()
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
