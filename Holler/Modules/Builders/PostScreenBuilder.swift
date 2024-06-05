//
//  PostScreenBıilder.swift
//  Holler
//
//  Created by Berke Parıldar on 3.06.2024.
//

import Foundation

final class PostScreenBuilder {
    static func create(postID: String, user: User, likeDelegate: LikeSyncDelegate? = nil, replyDelegate: ReplySyncDelegate? = nil) -> PostViewController {
        let viewModel = PostViewModel(postID: postID, user: user)
        let viewController = PostViewController()
        viewController.likeSyncDelegate = likeDelegate
        viewController.replySyncDelegate = replyDelegate
        viewController.viewModel = viewModel
        viewModel.delegate = viewController
        return viewController
    }
}
