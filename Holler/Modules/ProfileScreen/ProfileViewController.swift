//
//  ProfileViewController.swift
//  Holler
//
//  Created by Berke Parıldar on 20.05.2024.
//

import UIKit
import Kingfisher

class ProfileViewController: UIViewController, LoadingShowable {
    
    var viewModel: ProfileViewModel!
    var posts: [ProfilePost] = []
    
    lazy var bannerImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView;
    }()
    
    lazy var profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 28
        imageView.layer.borderWidth = 4
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView;
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 14)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var followInfoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var postsView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TableViewPostCell.self, forCellReuseIdentifier: "postCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showLoading()
        setupViews()
        viewModel.fetchUser { user, error in
            if let error = error {
                print("Error fetching user: \(error.localizedDescription)")
                return
            }
            if let user = user {
                self.configureWithUser(user: user)
            }
        }
    }
    
    private func configureWithUser(user: User) {
        nameLabel.text = user.name
        usernameLabel.text = "@\(user.username)"
        followInfoLabel.text = "\(user.followers.count) followers • \(user.following.count) following"
        if let profileImagePath = user.profileImage {
            viewModel.loadImage(from: profileImagePath) { [weak self] url in
                self?.profileImage.kf.setImage(with: url)
            }
        }
        if let bannerImagePath = user.bannerImage {
            viewModel.loadImage(from: bannerImagePath) { [weak self] url in
                self?.bannerImage.kf.setImage(with: url)
            }
        }
        viewModel.fetchPosts(with: user.posts)
    }
    
    func setupViews() {
        view.addSubview(bannerImage)
        NSLayoutConstraint.activate([
            bannerImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            bannerImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bannerImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bannerImage.heightAnchor.constraint(equalToConstant: 128)
        ])
        
        view.addSubview(profileImage)
        NSLayoutConstraint.activate([
            profileImage.topAnchor.constraint(equalTo: bannerImage.bottomAnchor, constant: -28),
            profileImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            profileImage.heightAnchor.constraint(equalToConstant: 56),
            profileImage.widthAnchor.constraint(equalToConstant: 56),
        ])
        
        view.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
        ])
        
        view.addSubview(usernameLabel)
        NSLayoutConstraint.activate([
            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            usernameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8)
        ])
        
        view.addSubview(followInfoLabel)
        NSLayoutConstraint.activate([
            followInfoLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 16),
            followInfoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8)
        ])
        
    }
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! TableViewPostCell
        cell.configureAsProfilePost(profileImage: profileImage.image ?? UIImage(systemName: "globe")!, name: nameLabel.text ?? "", username: usernameLabel.text ?? "", with: posts[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension ProfileViewController: ProfileDelegate {
    func fetchPostOutput(posts: [ProfilePost]) {
        self.posts = posts
        view.addSubview(postsView)
        NSLayoutConstraint.activate([
            postsView.topAnchor.constraint(equalTo: followInfoLabel.bottomAnchor, constant: 8),
            postsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            postsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            postsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        postsView.reloadData()
        hideLoading()
    }
}
