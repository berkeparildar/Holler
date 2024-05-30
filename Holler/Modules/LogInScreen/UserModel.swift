//
//  UserModel.swift
//  Holler
//
//  Created by Berke Parıldar on 19.05.2024.
//

import UIKit

struct User {
    let uid: String
    let name: String
    let username: String
    let followers: [String]
    let following: [String]
    let posts: [String]
    let profileImageURL: String?
    let bannerImageURL: String?
    var profileImage = UIImageView()
    var bannerImage = UIImageView()
    
    init(uid: String, data: [String: Any]) {
        self.uid = uid
        self.name = data["name"] as? String ?? ""
        self.followers = data["followers"] as? [String] ?? [String]()
        self.following = data["following"] as? [String] ?? [String]()
        self.posts = data["posts"] as? [String] ?? [String]()
        self.username = data["username"] as? String ?? ""
        self.profileImageURL = data["profileURL"] as? String
        self.bannerImageURL = data["bannerURL"] as? String
    }
}
