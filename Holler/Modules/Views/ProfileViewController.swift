//
//  ProfileViewController.swift
//  Holler
//
//  Created by Berke Parıldar on 20.05.2024.
//

import UIKit
import Kingfisher

protocol ProfileViewModelDelegate: AnyObject {
    func didFetchPosts(posts: [Post])
    func didFetchUser(user: User)
    func didFollowUser()
    func didUnfollowUser()
}

class ProfileViewController: UIViewController, LoadingShowable {
    
    var viewModel: ProfileViewModel!
    var posts: [Post] = []
    weak var likeSyncDelegate: LikeSyncDelegate?
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.delaysContentTouches = false
        tableView.register(PostCell.self, forCellReuseIdentifier: "postCell")
        tableView.register(PostImageCell.self, forCellReuseIdentifier: "postImageCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    lazy var followButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Follow", for: .normal)
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(didTapFollowButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var unfollowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Unfollow", for: .normal)
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.backgroundColor = .red
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(didTapUnfollowButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var editProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit Profile", for: .normal)
        button.setTitleColor(.gray, for: .selected)
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
    
    @objc func didTapFollowButton() {
        viewModel.followUser(targetID: viewModel.userID, currentID: UserService.shared.currentUser!.uid)
    }
    
    @objc func didTapUnfollowButton() {
        viewModel.unfollowUser(targetID: viewModel.userID, currentID: UserService.shared.currentUser!.uid)
    }
    
    private func configureMenu() {
            let option1 = UIAction(title: "Option 1", image: UIImage(systemName: "1.circle")) { action in
                print("Option 1 selected")
            }
            
            let option2 = UIAction(title: "Option 2", image: UIImage(systemName: "2.circle")) { action in
                print("Option 2 selected")
            }
            
            let option3 = UIAction(title: "Option 3", image: UIImage(systemName: "3.circle")) { action in
                print("Option 3 selected")
            }
            
            let menu = UIMenu(title: "", children: [option1, option2, option3])
            editProfileButton.menu = menu
            editProfileButton.showsMenuAsPrimaryAction = true
        }
    
    @objc func didTapEditButton() {
        let actionSheet = UIAlertController(title: nil, message: "Choose an option", preferredStyle: .actionSheet)
            
            // Add options
            let option1 = UIAlertAction(title: "Option 1", style: .default) { action in
                print("Option 1 selected")
            }
            let option2 = UIAlertAction(title: "Option 2", style: .default) { action in
                print("Option 2 selected")
            }
            let option3 = UIAlertAction(title: "Option 3", style: .default) { action in
                print("Option 3 selected")
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            actionSheet.addAction(option1)
            actionSheet.addAction(option2)
            actionSheet.addAction(option3)
            actionSheet.addAction(cancel)
            
            // Present the action sheet
            present(actionSheet, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        configureMenu()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("called")
        viewModel.fetchPostsForProfile()
    }
    
    private func configureWithUser(user: User) {
        self.navigationItem.title = user.username
        nameLabel.text = user.name
        usernameLabel.text = "@\(user.username)"
        profileImage.kf.setImage(with: URL(string: user.profileImageURL))
        bannerImage.kf.setImage(with: URL(string: user.bannerImageURL))
        followInfoLabel.text = "\(user.followers.count) followers • \(user.following.count) following"
        let currentUser = UserService.shared.currentUser!
        if user.uid == currentUser.uid {
            followButton.isHidden = true
            unfollowButton.isHidden = true
        } else {
            editProfileButton.isHidden = true
            if currentUser.following.contains(user.uid) {
                followButton.isHidden = true
            } else {
                unfollowButton.isHidden = true
            }
        }
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        
        tableView.bounces = false
        tableView.alwaysBounceVertical = false
        let headerView = createTableHeaderView()
        tableView.tableHeaderView = headerView
    }
    
    private func createTableHeaderView() -> UIView {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 240))
        let customView = UIView(frame: headerView.frame)
        customView.translatesAutoresizingMaskIntoConstraints = false
        customView.addSubview(bannerImage)
        customView.addSubview(profileImage)
        customView.addSubview(nameLabel)
        customView.addSubview(usernameLabel)
        customView.addSubview(followInfoLabel)
        customView.addSubview(followButton)
        customView.addSubview(unfollowButton)
        customView.addSubview(editProfileButton)
        
        headerView.addSubview(customView)
        NSLayoutConstraint.activate([
            customView.topAnchor.constraint(equalTo: headerView.topAnchor),
            customView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            customView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            customView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            
            bannerImage.topAnchor.constraint(equalTo: customView.topAnchor),
            bannerImage.leadingAnchor.constraint(equalTo: customView.leadingAnchor),
            bannerImage.trailingAnchor.constraint(equalTo: customView.trailingAnchor),
            bannerImage.heightAnchor.constraint(equalToConstant: 128),
            
            profileImage.topAnchor.constraint(equalTo: bannerImage.bottomAnchor, constant: -28),
            profileImage.leadingAnchor.constraint(equalTo: customView.leadingAnchor, constant: 8),
            profileImage.heightAnchor.constraint(equalToConstant: 56),
            profileImage.widthAnchor.constraint(equalToConstant: 56),
            
            nameLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: customView.leadingAnchor, constant: 8),
            
            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            usernameLabel.leadingAnchor.constraint(equalTo: customView.leadingAnchor, constant: 8),
            
            followInfoLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8),
            followInfoLabel.leadingAnchor.constraint(equalTo: customView.leadingAnchor, constant: 8),
            
            followButton.heightAnchor.constraint(equalToConstant: 32),
            followButton.widthAnchor.constraint(equalToConstant: 100),
            followButton.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            followButton.trailingAnchor.constraint(equalTo: customView.trailingAnchor, constant: -8),
            
            unfollowButton.heightAnchor.constraint(equalToConstant: 32),
            unfollowButton.widthAnchor.constraint(equalToConstant: 100),
            unfollowButton.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            unfollowButton.trailingAnchor.constraint(equalTo: customView.trailingAnchor, constant: -8),
            
            editProfileButton.heightAnchor.constraint(equalToConstant: 32),
            editProfileButton.widthAnchor.constraint(equalToConstant: 100),
            editProfileButton.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            editProfileButton.trailingAnchor.constraint(equalTo: customView.trailingAnchor, constant: -8),
        ])
        return headerView
    }
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.row]
        if post.hasImage {
            let cell = tableView.dequeueReusableCell(withIdentifier: "postImageCell", for: indexPath) as! PostImageCell
            cell.configure(post: posts[indexPath.row])
            cell.delegate = self
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostCell
        cell.delegate = self
        cell.disableProfileImageButton()
        cell.configure(post: posts[indexPath.row])
        return cell
    }
}

extension ProfileViewController: ProfileViewModelDelegate {
    func didUnfollowUser() {
        self.followButton.isHidden = false
        self.unfollowButton.isHidden = true
        var user = viewModel.user!
        if let index = user.followers.firstIndex(of: UserService.shared.currentUser!.uid) {
            user.followers.remove(at: index)
        }
        followInfoLabel.text = "\(user.followers.count) followers • \(user.following.count) following"
    }
    
    func didFollowUser() {
        self.followButton.isHidden = true
        self.unfollowButton.isHidden = false
        var user = viewModel.user!
        user.followers.append(UserService.shared.currentUser!.uid)
        followInfoLabel.text = "\(user.followers.count) followers • \(user.following.count) following"
    }
    
    func didFetchUser(user: User) {
        self.configureWithUser(user: user)
    }
    
    func didFetchPosts(posts: [Post]) {
        self.posts = posts.sorted(by: { $0.time > $1.time })
        tableView.reloadData()
    }
}

extension ProfileViewController: CellDelegate {
    func didTapUserProfile(userID: String, user: User?) {}
    
    func didLikePost(postID: String) {
        let likedPostIndex = posts.firstIndex { post in
            post.id == postID
        }
        guard let likedPostIndex = likedPostIndex else { return }
        posts[likedPostIndex].likes.append(UserService.shared.currentUser!.uid)
        viewModel.didLikePost(postID: postID)
        likeSyncDelegate?.likedPost(postID: postID)
        tableView.reloadRows(at: [IndexPath(row: likedPostIndex, section: 0)], with: .fade)
    }
    
    func didUnlikePost(postID: String) {
        let unlikedPostIndex = posts.firstIndex { post in
            post.id == postID
        }
        guard let unlikedPostIndex = unlikedPostIndex else { return }
        if let index = posts[unlikedPostIndex].likes.firstIndex(of: UserService.shared.currentUser!.uid) {
            posts[unlikedPostIndex].likes.remove(at: index)
            viewModel.didUnlikePost(postID: postID)
            likeSyncDelegate?.unlikedPost(postID: postID)
            tableView.reloadRows(at: [IndexPath(row: unlikedPostIndex, section: 0)], with: .fade)
        }
    }
}
