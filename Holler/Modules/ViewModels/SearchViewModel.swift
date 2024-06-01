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
        
        // Enter the group for the user lookup task
        dispatchGroup.enter()
        FirebaseService.shared.lookForUser(with: search) { userIDs, error in
            if let error = error {
                print("Error looking for user: \(error.localizedDescription)")
                dispatchGroup.leave() // Leave the group in case of error
                return
            }
            
            guard let userIDs = userIDs else {
                print("No user IDs found for search: \(search)")
                dispatchGroup.leave() // Leave the group if no user IDs found
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
            
            // Leave the group for the user lookup task after initiating all fetch user tasks
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            self.delegate?.didFetchUsers(users: users)
        }
    }

}
