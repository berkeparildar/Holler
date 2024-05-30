//
//  HomeViewController.swift
//  Holler
//
//  Created by Berke Parıldar on 15.05.2024.
//

import Foundation
import FirebaseFirestore

final class HomeViewModel {
    
    private let db = Firestore.firestore()
    
    func fetchPostsForHomePage(completion: @escaping ([HomePagePost]?, Error?) -> Void) {
        guard let currentUser = UserService.shared.currentUser else {
            completion(nil, NSError(domain: "UserService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Current user not loaded"]))
            return
        }
        
        var followingIDs = currentUser.following
        followingIDs.append(currentUser.uid)
        
        if followingIDs.isEmpty {
            completion([], nil)
            return
        }
        
        var posts = [HomePagePost]()
        let dispatchGroup = DispatchGroup()
        for userID in followingIDs {
            let userRef = db.collection("users").document(userID)
            dispatchGroup.enter()
            userRef.getDocument { (document, error) in
                if let error = error {
                    dispatchGroup.leave()
                    print("Error fetching user document: \(error.localizedDescription)")
                    return
                }
                guard let document = document, document.exists, let data = document.data(), let name = data["name"] as? String, let username = data["username"] as? String, let profileImagePath = data["profileURL"] as? String, let postIDs = data["posts"] as? [String] else {
                    dispatchGroup.leave()
                    return
                }
                let postRef = self.db.collection("posts")
                for postID in postIDs {
                    dispatchGroup.enter()
                    postRef.document(postID).getDocument { (postDocument, error) in
                        if let error = error {
                            print("Error fetching post: \(error.localizedDescription)")
                            dispatchGroup.leave()
                            return
                        }
                        guard let postDocument = postDocument, postDocument.exists, let postData = postDocument.data() else {
                            dispatchGroup.leave()
                            return
                        }
                        let post = HomePagePost(id: postID, profileImagePath: profileImagePath, name: name, username: username, data: postData)
                        posts.append(post)
                        dispatchGroup.leave()
                    }
                }
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) {
            completion(posts, nil)
        }
    }
}
