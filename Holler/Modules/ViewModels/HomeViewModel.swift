//
//  HomeViewController.swift
//  Holler
//
//  Created by Berke Parıldar on 15.05.2024.
//

import Foundation

final class HomeViewModel {
    
    weak var delegate: HomeViewModelDelegate?
        
    func fetchPostsForHomePage() {
        guard let currentUser = UserService.shared.currentUser else { return }
        var followingIDs = currentUser.following
        followingIDs.append(currentUser.uid)
        var posts = [Post]()
        let dispatchGroup = DispatchGroup()
        for userID in followingIDs {
            dispatchGroup.enter()
            FirebaseService.shared.fetchUser(userID: userID) { user, error in
                if let error = error {
                    print("There was a problem fetching user \(userID): " + error.localizedDescription)
                    dispatchGroup.leave()
                    return
                }
                guard let user = user else {
                    dispatchGroup.leave()
                    return
                }
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
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) {
            self.delegate?.didFetchPosts(posts: posts)
        }
    }
    
    func didLikePost(postID: String) {
        FirebaseService.shared.likePost(postID: postID) { error in
            if let error = error {
                print("There was a problem liking post: \(error.localizedDescription)")
            }
        }
    }
    
    func didUnlikePost(postID: String) {
        FirebaseService.shared.unlikePost(postID: postID) { error in
            if let error = error {
                print("There was a problem unliking post: \(error.localizedDescription)")
            }
        }
    }
}
