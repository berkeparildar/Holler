//
//  PostCreateScreenBuilder.swift
//  Holler
//
//  Created by Berke Parıldar on 29.05.2024.
//

import Foundation

final class PostCreateScreenBuilder {
    static func create(delegate: PostCreationDelegate) -> PostCreateViewController {
        let viewController = PostCreateViewController()
        let viewModel = PostCreateViewModel()
        viewModel.delegate = delegate
        viewController.viewModel = viewModel
        return viewController
    }
}
