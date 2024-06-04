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
    var followers: [String]
    var following: [String]
    var posts: [String]
    var profileImageURL: String
    var bannerImageURL: String
    
    init(uid: String, data: [String: Any]) {
        self.uid = uid
        self.name = data["name"] as? String ?? ""
        self.followers = data["followers"] as? [String] ?? [String]()
        self.following = data["following"] as? [String] ?? [String]()
        self.posts = data["posts"] as? [String] ?? [String]()
        self.username = data["username"] as? String ?? ""
        self.profileImageURL = data["profileURL"] as? String ?? ""
        self.bannerImageURL = data["bannerURL"] as? String ?? ""
    }
}
