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
    var user: User!

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ProfilePostCell.self, forCellReuseIdentifier: "postCell")
        tableView.register(ProfilePostImageCell.self, forCellReuseIdentifier: "postImageCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    lazy var bannerImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 28
        imageView.layer.borderWidth = 4
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
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
        profileImage.image = user.profileImage.image
        bannerImage.image = user.bannerImage.image
        followInfoLabel.text = "\(user.followers.count) followers • \(user.following.count) following"
        self.viewModel.fetchPosts(with: user.posts)
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])

        let headerView = createTableHeaderView()
        tableView.tableHeaderView = headerView
    }

    private func createTableHeaderView() -> UIView {
        let headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addSubview(bannerImage)
        headerView.addSubview(profileImage)
        headerView.addSubview(nameLabel)
        headerView.addSubview(usernameLabel)
        headerView.addSubview(followInfoLabel)

        NSLayoutConstraint.activate([
            bannerImage.topAnchor.constraint(equalTo: headerView.topAnchor),
            bannerImage.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            bannerImage.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            bannerImage.heightAnchor.constraint(equalToConstant: 128),
            
            profileImage.topAnchor.constraint(equalTo: bannerImage.bottomAnchor, constant: -28),
            profileImage.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 8),
            profileImage.heightAnchor.constraint(equalToConstant: 56),
            profileImage.widthAnchor.constraint(equalToConstant: 56),
            
            nameLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 8),
            
            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            usernameLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 8),
            
            followInfoLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 16),
            followInfoLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 8),
            followInfoLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
        ])
        
        headerView.layoutIfNeeded()
        let headerHeight = followInfoLabel.frame.maxY + 8
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: headerHeight)
        
        return headerView
    }
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if posts.isEmpty {
            return 1
        }
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if posts.isEmpty {
            let cell = UITableViewCell()
            let activityIndicator = UIActivityIndicatorView()
            cell.contentView.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            return cell
        }
        let post = posts[indexPath.row]
        if post.hasImage {
            let cell = tableView.dequeueReusableCell(withIdentifier: "postImageCell", for: indexPath) as! ProfilePostImageCell
            cell.configure(profileImage: UserService.shared.currentUser?.profileImage.image ?? UIImage(systemName: "globe")!, name: nameLabel.text ?? "", username: usernameLabel.text ?? "", with: posts[indexPath.row])
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! ProfilePostCell
        cell.configure(profileImage: UserService.shared.currentUser?.profileImage.image ?? UIImage(systemName: "globe")!, name: nameLabel.text ?? "", username: usernameLabel.text ?? "", with: posts[indexPath.row])
        return cell
    }
}

extension ProfileViewController: ProfileDelegate {
    func fetchPostOutput(posts: [ProfilePost]) {
        //self.posts = posts
        tableView.reloadData()
    }
}
