//
//  ProfileScreenBuilder.swift
//  Holler
//
//  Created by Berke Parıldar on 29.05.2024.
//

import Foundation

final class ProfileScreenBuilder {
    static func create(userID: String) -> ProfileViewController {
        let viewController = ProfileViewController()
        let viewModel = ProfileViewModel(userID: userID)
        viewController.viewModel = viewModel
        viewModel.delegate = viewController
        return viewController
    }
}
