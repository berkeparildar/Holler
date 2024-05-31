//
//  SignUpScreenBuilder.swift
//  Holler
//
//  Created by Berke Parıldar on 13.05.2024.
//

import Foundation

final class SignUpScreenBuilder {
    static func create() -> SignUpViewController {
        let viewController = SignUpViewController()
        let viewModel = SignUpViewModel()
        viewController.viewModel = viewModel
        return viewController
    }
}
