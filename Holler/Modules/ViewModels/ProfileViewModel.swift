//
//  ProfileViewModel.swift
//  Holler
//
//  Created by Berke Parıldar on 20.05.2024.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

final class ProfileViewModel {
    let userID: String
    var user: User?
    weak var delegate: ProfileViewModelDelegate?
    
    init(userID: String, user: User?) {
        self.userID = userID
        self.user = user
    }
    
    func fetchOwnPosts() {
        let user = UserService.shared.currentUser!
        delegate?.didFetchUser(user: user)
        var posts = [Post]()
        let dispatchGroup = DispatchGroup()
        for postID in user.posts {
            dispatchGroup.enter()
            FirebaseService.shared.fetchPost(postID: postID, user: user) { post, error in
                if let error = error {
                    print("There was a problem fetching post \(postID): " + error.localizedDescription)
                    dispatchGroup.leave()
                    return
                }
                guard let post = post else {
                    dispatchGroup.leave()
                    return
                }
                posts.append(post)
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) {
            self.delegate?.didFetchPosts(posts: posts)
        }
    }
    
    func fetchTargetPosts() {
        var posts = [Post]()
        FirebaseService.shared.fetchUser(userID: userID) { [weak self] user, error in
            guard let self = self else { return }
            if let error = error {
                print("There was a problem fetching the user" + error.localizedDescription)
                return
            }
            guard let user = user else { return }
            delegate?.didFetchUser(user: user)
            let dispatchGroup = DispatchGroup()
            for postID in user.posts {
                dispatchGroup.enter()
                FirebaseService.shared.fetchPost(postID: postID, user: user) { post, error in
                    if let error = error {
                        print("There was a problem fetching post \(postID): " + error.localizedDescription)
                        dispatchGroup.leave()
                        return
                    }
                    guard let post = post else {
                        dispatchGroup.leave()
                        return
                    }
                    posts.append(post)
                    dispatchGroup.leave()
                }
            }
            dispatchGroup.notify(queue: .main) {
                self.delegate?.didFetchPosts(posts: posts)
            }
        }
    }
    
    func fetchPostsForProfile() {
        var posts = [Post]()
        if user != nil {
            fetchOwnPosts()
        } else {
            fetchTargetPosts()
        }
    }
}
