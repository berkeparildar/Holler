//
//  SearchViewModel.swift
//  Holler
//
//  Created by Berke Parıldar on 1.06.2024.
//

import Foundation

final class SearchViewModel {
    weak var delegate: SearchViewModelDelegate?
    
    func fetchUser(search: String) {
        var users = [User]()
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        FirebaseService.shared.lookForUser(with: search) { userIDs, error in
            if let error = error {
                print("Error looking for user: \(error.localizedDescription)")
                dispatchGroup.leave()
                return
            }
            guard let userIDs = userIDs else {
                print("No user IDs found for search: \(search)")
                dispatchGroup.leave()
                self.delegate?.didFetchUsers(users: [])
                return
            }
            for userID in userIDs {
                dispatchGroup.enter()
                FirebaseService.shared.fetchUser(userID: userID) { user, error in
                    if let error = error {
                        print("Error fetching user \(userID): \(error.localizedDescription)")
                    } else if let user = user {
                        users.append(user)
                    }
                    dispatchGroup.leave()
                }
            }
            dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: .main) {
            self.delegate?.didFetchUsers(users: users)
        }
    }
}
