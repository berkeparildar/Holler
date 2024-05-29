//
//  ProfilePostModel.swift
//  Holler
//
//  Created by Berke Parıldar on 20.05.2024.
//

import Foundation

struct ProfilePost {
    let id: String
    let time: Int
    let postText: String
    let hasImage: Bool
    let contentImagePath: String
    let replyCount: Int
    let likeCount: Int
    let replies: [String]
    let likes: [String]
    
    init(id: String, data: [String: Any]) {
        self.id = id
        self.postText = data["text"] as? String ?? ""
        self.hasImage = data["hasImage"] as? Bool ?? false
        self.contentImagePath = data["image"] as? String ?? ""
        self.replyCount = data["replyCount"] as? Int ?? 0
        self.likeCount = data["likeCount"] as? Int ?? 0
        self.replies = data["replies"] as? [String] ?? [String]()
        self.likes = data["likes"] as? [String] ?? [String]()
        self.time = data["time"] as? Int ?? 0
    }
}
