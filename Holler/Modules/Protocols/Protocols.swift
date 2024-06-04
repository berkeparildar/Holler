//
//  Protocols.swift
//  Holler
//
//  Created by Berke Parıldar on 4.06.2024.
//

import Foundation

protocol PostCreationDelegate: AnyObject {
    func didPost()
}

protocol CellDelegate: AnyObject {
    func didTapLikeButton(postID: String)
    func didTapUnlikeButton(postID: String)
    func didTapUserProfile(userID: String, user: User?)
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
