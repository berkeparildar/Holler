//
//  PostCreateViewModel.swift
//  Holler
//
//  Created by Berke Parıldar on 29.05.2024.
//

import Foundation
import UIKit
import FirebaseStorage
import FirebaseFirestore

final class PostCreateViewModel {
    
    weak var delegate: PostCreationDelegate?
    weak var viewDelegate: PostCreateViewModelDelegate?
    
    func post(text: String, imageData: Data?) {
        FirebaseService.shared.createPost(text: text, imageData: imageData) { success, error in
            if let error = error {
                print("There was an error creating a post: " + error.localizedDescription)
            }
            if success {
                self.delegate?.didPost()
                self.viewDelegate?.didPost()
            }
        }
    }
}
