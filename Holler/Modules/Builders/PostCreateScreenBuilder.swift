//
//  PostCreateScreenBuilder.swift
//  Holler
//
//  Created by Berke Parıldar on 29.05.2024.
//

import Foundation

final class PostCreateScreenBuilder {
    static func create(delegate: PostCreationDelegate, rootPostID: String? = nil) -> PostCreateViewController {
        let viewController = PostCreateViewController()
        let viewModel = PostCreateViewModel(rootPostID: rootPostID)
        viewModel.delegate = delegate
        viewModel.viewDelegate = viewController
        viewController.viewModel = viewModel
        return viewController
    }
}
