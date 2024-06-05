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
    var rootPostID: String?
    
    init(delegate: PostCreationDelegate? = nil, viewDelegate: PostCreateViewModelDelegate? = nil, rootPostID: String? = nil) {
        self.delegate = delegate
        self.viewDelegate = viewDelegate
        self.rootPostID = rootPostID
    }
    
    func post(text: String, imageData: Data?) {
        FirebaseService.shared.createPost(text: text, imageData: imageData) { postID, error in
            if let error = error {
                print("There was an error creating a post: " + error.localizedDescription)
            }
            guard let postID = postID else { return }
            self.delegate?.didPost(postID: postID)
            self.viewDelegate?.didPost()
        }
    }
    
    func reply(text: String, imageData: Data?) {
        guard let rootPostID = rootPostID else { return }
        FirebaseService.shared.createReply(text: text, imageData: imageData, rootPostID: rootPostID) { postID, error in
            if let error = error {
                print("There was an error creating a post: " + error.localizedDescription)
            }
            guard let postID = postID else { return }
            self.delegate?.didPost(postID: postID)
            self.viewDelegate?.didPost()
        }
    }
}
