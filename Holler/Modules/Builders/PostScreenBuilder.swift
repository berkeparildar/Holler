//
//  PostScreenBıilder.swift
//  Holler
//
//  Created by Berke Parıldar on 3.06.2024.
//

import Foundation

final class PostScreenBuilder {
    static func create(post: Post, likeDelegate: LikeSyncDelegate? = nil) -> PostViewController {
        let viewModel = PostViewModel(post: post)
        let viewController = PostViewController()
        viewController.likeSyncDelegate = likeDelegate
        viewController.viewModel = viewModel
        viewModel.delegate = viewController
        return viewController
    }
}
