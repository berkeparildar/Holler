//
//  SplashBuilder.swift
//  Holler
//
//  Created by Berke Parıldar on 13.05.2024.
//

import Foundation

import Foundation

final class SplashScreenBuilder {
    static func create() -> SplashViewController {
        let viewModel = SplashViewModel()
        let viewController = SplashViewController()
        viewController.viewModel = viewModel
        viewModel.delegate = viewController
        return viewController
    }
}
