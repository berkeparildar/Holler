//
//  Protocols.swift
//  Holler
//
//  Created by Berke Parıldar on 4.06.2024.
//

import Foundation

protocol PostCreationDelegate: AnyObject {
    func didPost(postID: String)
}

protocol CellDelegate: AnyObject {
    func didTapLikeButton(postID: String)
    func didTapUnlikeButton(postID: String)
    func didTapUserProfile(userID: String, user: User?)
}

protocol SplashViewModelDelegate: AnyObject {
    func showInternetError()
    func navigateToHomePage()
}

protocol HomeViewModelDelegate: AnyObject {
    func didFetchPosts(posts: [Post])
}

protocol ProfileViewModelDelegate: AnyObject {
    func didFetchPosts(posts: [Post])
    func didFetchUser(user: User)
    func didFollowUser()
    func didUnfollowUser()
    func didChangeProfilePicture(success: Bool)
    func didChangeBannerPicture(success: Bool)
}

protocol LikeSyncDelegate: AnyObject {
    func unlikedPost(postID: String)
    func likedPost(postID: String)
}

protocol ReplySyncDelegate: AnyObject {
    func repliedToPost(postID: String, rootPostID: String)
}


protocol PostViewModelDelegate: AnyObject {
    func didFetchPosts(posts: [Post])
}


