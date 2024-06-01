//
//  PostModel.swift
//  Holler
//
//  Created by Berke Parıldar on 15.05.2024.
//

import Foundation

struct Post {
    let userID: String
    let id: String
    let time: Int
    let postText: String
    let hasImage: Bool
    let contentImageURL: String
    let replies: [String]
    var likes: [String]
    let user: User?
    
    init(id: String, data: [String: Any], user: User?) {
        self.id = id
        self.userID = data["userID"] as? String ?? ""
        self.postText = data["text"] as? String ?? ""
        self.hasImage = data["hasImage"] as? Bool ?? false
        self.contentImageURL = data["image"] as? String ?? ""
        self.replies = data["replies"] as? [String] ?? [String]()
        self.likes = data["likes"] as? [String] ?? [String]()
        self.time = data["time"] as? Int ?? 0
        self.user = user
    }
}
