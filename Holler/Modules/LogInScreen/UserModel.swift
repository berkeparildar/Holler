//
//  UserModel.swift
//  Holler
//
//  Created by Berke Parıldar on 19.05.2024.
//

import Foundation

struct User {
    let uid: String
    let name: String
    let username: String
    let followers: [String]
    let following: [String]
    let posts: [String]
    let profileImage: String?
    let bannerImage: String?
    
    init(uid: String, data: [String: Any]) {
        self.uid = uid
        self.name = data["name"] as? String ?? ""
        self.followers = data["followers"] as? [String] ?? [String]()
        self.following = data["following"] as? [String] ?? [String]()
        self.posts = data["posts"] as? [String] ?? [String]()
        self.username = data["username"] as? String ?? ""
        self.profileImage = data["profileURL"] as? String
        self.bannerImage = data["bannerURL"] as? String
    }
}
