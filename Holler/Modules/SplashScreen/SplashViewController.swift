//
//  SplashViewController.swift
//  Holler
//
//  Created by Berke Parıldar on 13.05.2024.
//

import UIKit
import FirebaseAuth
import KeychainAccess

class SplashViewController: UIViewController, ShowAlert {
    private let keychain = Keychain(service: "com.bprldr.Holler")
    var viewModel: SplashViewModel!
    
    var background: UIView = {
        var backgroundView = UIView()
        backgroundView.backgroundColor = .red
        return backgroundView
    }()
    
    var splashLogo: UIImageView = {
        var logo = UIImageView()
        logo.image = UIImage(systemName: "globe")
        return logo
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        setupViews()
        viewModel.checkInternetConnection()
    }
    
    func setupViews() {
        self.background.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(background)
        splashLogo.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(splashLogo)
        NSLayoutConstraint.activate([
            self.background.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.background.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.background.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.background.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.splashLogo.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.splashLogo.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            self.splashLogo.widthAnchor.constraint(equalToConstant: 120),
            self.splashLogo.heightAnchor.constraint(equalToConstant: 120),
            
        ])
    }
}

extension SplashViewController: SplashViewModelDelegate {
    
    func navigateToHomePage() {
        guard let window = self.view.window else { return }
        if let uid = try? keychain.get("uid"), !uid.isEmpty {
            UserService.shared.fetchCurrentUser { user, error in
                if let error = error {
                    print(error.localizedDescription)
                }
                if let user = user {
                    let tabBarController = UITabBarController()
                    let searchViewController = SearchViewController()
                    let searchNavController = UINavigationController(rootViewController: searchViewController)
                    searchNavController.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 0)
                    let homeViewController = HomeBuilder.create()
                    let homeNavController = UINavigationController(rootViewController: homeViewController)
                    homeNavController.tabBarItem = UITabBarItem(title: "Feed", image: UIImage(systemName: "newspaper.fill"), tag: 1)
                    let profileViewController = ProfileScreenBuilder.create(userID: user.uid)
                    let profileNavController = UINavigationController(rootViewController: profileViewController)
                    profileNavController.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.crop.circle.fill"), tag: 2)
                    tabBarController.viewControllers = [homeNavController, searchNavController, profileNavController]
                    window.rootViewController = tabBarController
                }
            }
            
        } else {
            let loginVC = LogInScreenBuilder.create()
            let navigationController = UINavigationController(rootViewController: loginVC)
            window.rootViewController = navigationController
        }
    }
    
    func showInternetError() {
        showAlert(title: "İnternet bağlantısı yok", message: "Bağlantıyı sağlayıp tekrar deneyin")
    }
}
