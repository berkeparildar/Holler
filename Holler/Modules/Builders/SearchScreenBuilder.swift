//
//  SearchViewBuilder.swift
//  Holler
//
//  Created by Berke Parıldar on 1.06.2024.
//

import Foundation

final class SearchScreenBuilder {
    static func create() -> SearchViewController {
        let viewController = SearchViewController()
        let viewModel = SearchViewModel()
        viewController.viewModel = viewModel
        viewModel.delegate = viewController
        return viewController
    }
}
