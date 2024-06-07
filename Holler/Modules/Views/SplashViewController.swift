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
        return backgroundView
    }()
    
    var splashLogo: UIImageView = {
        var logo = UIImageView()
        logo.contentMode = .scaleAspectFit
        logo.image = UIImage(named: "logo")
        return logo
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
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
            self.splashLogo.widthAnchor.constraint(equalToConstant: 360),
            self.splashLogo.heightAnchor.constraint(equalToConstant: 360),
            
        ])
    }
}

extension SplashViewController: SplashViewModelDelegate {
    func navigateToHomePage() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: { [weak self] in
            guard let self = self, let window = self.view.window else { return }
            if let uid = try? keychain.get("uid"), !uid.isEmpty {
                UserService.shared.fetchCurrentUser { user, error in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                    if let user = user {
                        window.rootViewController = TabBarBuilder.create(user: user)
                    }
                }
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.view.layer.opacity = 0
                } completion: { _ in
                    let loginVC = LogInScreenBuilder.create()
                    let navigationController = UINavigationController(rootViewController: loginVC)
                    window.rootViewController = navigationController
                }
            }
        })
    }
    
    func showInternetError() {
        showAlert(title: "İnternet bağlantısı yok", message: "Bağlantıyı sağlayıp tekrar deneyin")
    }
}
