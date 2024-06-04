//
//  ShowLoading.swift
//  Holler
//
//  Created by Berke Parıldar on 13.05.2024.
//

import UIKit

protocol LoadingShowable where Self: UIViewController {
    func showLoading()
    func hideLoading()
}

extension LoadingShowable {
    func showLoading() {
        LoadingView.shared.startLoading()
    }
    
    func hideLoading() {
        LoadingView.shared.hideLoading()
    }
}

final class LoadingView {
    
    static let shared = LoadingView()
    
    private var backgroundView: UIView!
    private var indicator: UIActivityIndicatorView!
    
    
    private init() {
        setupViews()
    }
    
    private func setupViews() {
        backgroundView = UIView()
        backgroundView.backgroundColor = .black.withAlphaComponent(0.5)
        backgroundView.frame = UIScreen.main.bounds
        
        indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        backgroundView.addSubview(indicator)
        
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor),
            indicator.widthAnchor.constraint(equalToConstant: 120),
            indicator.heightAnchor.constraint(equalToConstant: 120)
        ])
        
    }
    
    func startLoading() {
        indicator.startAnimating()
        UIApplication.shared.windows.first(where: \.isKeyWindow)?.addSubview(backgroundView)
    }
    
    func hideLoading() {
        DispatchQueue.main.async {
            self.indicator.stopAnimating()
            self.backgroundView.removeFromSuperview()
        }
    }
}
