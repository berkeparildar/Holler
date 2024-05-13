//
//  LogInScreenBuilder.swift
//  Holler
//
//  Created by Berke Parıldar on 13.05.2024.
//

import Foundation

final class LogInScreenBuilder {
    static func create() -> LogInViewController {
        let viewController = LogInViewController()
        let viewModel = LogInViewModel()
        viewController.viewModel = viewModel
        viewModel.delegate = viewController
        return viewController
    }
}
