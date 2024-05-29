//
//  HomeBuilder.swift
//  Holler
//
//  Created by Berke Parıldar on 20.05.2024.
//

import Foundation

final class HomeBuilder {
    static func create() -> HomeViewController {
        let viewModel = HomeViewModel()
        let viewController = HomeViewController()
        viewController.viewModel = viewModel
        return viewController
    }
}
