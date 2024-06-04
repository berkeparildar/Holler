//
//  PostViewModel.swift
//  Holler
//
//  Created by Berke Parıldar on 3.06.2024.
//

import Foundation


final class PostViewModel {
    var post: Post
    weak var delegate: PostViewModelDelegate?
    
    init(post: Post) {
        self.post = post
    }
    
    func fetchReplies() {
        let replyIDs = post.replies
        var replies = [Post]()
        let dispatchGroup = DispatchGroup()
        for reply in replyIDs {
            dispatchGroup.enter()
            FirebaseService.shared.fetchPost(postID: reply, user: nil) { post, error in
                if let error = error {
                    print("There was an error fetching replies \(error.localizedDescription)")
                    dispatchGroup.leave()
                }
                if var post = post {
                    dispatchGroup.enter()
                    FirebaseService.shared.fetchUser(userID: post.userID) { user, error in
                        if let error = error {
                            print("There was en error fetching user: \(error.localizedDescription)")
                            dispatchGroup.leave()
                        }
                        if let user = user {
                            post.user = user
                            replies.append(post)
                            dispatchGroup.leave()
                        }
                    }
                    dispatchGroup.leave()
                }
            }
        }
        dispatchGroup.notify(queue: .main) {
            self.delegate?.didFetchPosts(posts: replies)
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
