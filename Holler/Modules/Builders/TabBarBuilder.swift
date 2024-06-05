//
//  TabBarBuilder.swift
//  Holler
//
//  Created by Berke Parıldar on 5.06.2024.
//

import UIKit

final class TabBarBuilder {
    static func create(user: User) -> UITabBarController {
        let tabBarController = UITabBarController()
        let searchViewController = SearchScreenBuilder.create()
        let searchNavController = UINavigationController(rootViewController: searchViewController)
        searchNavController.navigationBar.standardAppearance = NavigationBarStyle.setStyle()
        searchNavController.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 0)
        let homeViewController = HomeBuilder.create()
        homeViewController.title = "Feed"
        let homeNavController = UINavigationController(rootViewController: homeViewController)
        homeNavController.navigationBar.standardAppearance = NavigationBarStyle.setStyle()
        homeNavController.tabBarItem = UITabBarItem(title: "Feed", image: UIImage(systemName: "newspaper.fill"), tag: 1)
        let profileViewController = ProfileScreenBuilder.create(userID: user.uid, user: user)
        let profileNavController = UINavigationController(rootViewController: profileViewController)
        profileNavController.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.crop.circle.fill"), tag: 2)
        profileNavController.navigationBar.standardAppearance = NavigationBarStyle.setStyle()
        profileViewController.likeSyncDelegate = homeViewController
        tabBarController.viewControllers = [searchNavController, homeNavController, profileNavController]
        tabBarController.selectedIndex = 1
        tabBarController.tabBar.standardAppearance = TabBarStyle.setStyle()
        return tabBarController
    }
}
