//
//  SplashViewModel.swift
//  Holler
//
//  Created by Berke Parıldar on 13.05.2024.
//

import Foundation
import Network

final class SplashViewModel {
    
    weak var delegate: SplashViewModelDelegate?
    
    func checkInternetConnection() {
        let networkMonitor = NWPathMonitor()
        networkMonitor.pathUpdateHandler = { [weak self] path in
            if path.status == .satisfied {
                DispatchQueue.main.async {
                    self?.delegate?.navigateToHomePage()
                }
            } else {
                DispatchQueue.main.async {
                    self?.delegate?.showInternetError()
                }
            }
            networkMonitor.cancel()
        }
        let queue = DispatchQueue.global(qos: .background)
        networkMonitor.start(queue: queue)
    }
}
