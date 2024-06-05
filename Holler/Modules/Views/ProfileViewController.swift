//
//  ProfileViewController.swift
//  Holler
//
//  Created by Berke Parıldar on 20.05.2024.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController, MessageShowable, LoadingShowable {
    
    var viewModel: ProfileViewModel!
    var posts: [Post] = []
    var isSelectingProfileImage: Bool = false
    weak var likeSyncDelegate: LikeSyncDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchPostsForProfile()
    }
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.delaysContentTouches = false
        tableView.bounces = false
        tableView.alwaysBounceVertical = false
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
        button.addTarget(self, action: #selector(didTapEditButton), for: .touchUpInside)
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
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 40
        imageView.layer.borderWidth = 4
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var followInfoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var postsLabel: UILabel = {
        let label = UILabel()
        label.text = "Posts"
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    @objc func didTapFollowButton() {
        viewModel.followUser(targetID: viewModel.userID, currentID: UserService.shared.currentUser!.uid)
    }
    
    @objc func didTapUnfollowButton() {
        viewModel.unfollowUser(targetID: viewModel.userID, currentID: UserService.shared.currentUser!.uid)
    }
    
    @objc func didTapEditButton() {
        let menuVC = MenuViewController(actions: [
            Action(title: "Change Profile Picture",
                   image: UIImage(systemName: "person.fill"),
                   handler: { [weak self] in
                       guard let self = self else { return }
                       self.dismiss(animated: true)
                       self.isSelectingProfileImage = true
                       self.selectImage()
                   }),
            Action(title: "Change Banner Picture",
                   image: UIImage(systemName: "photo.fill"),
                   handler: { [weak self] in
                       guard let self = self else { return }
                       self.isSelectingProfileImage = false
                       self.selectImage()
                       self.dismiss(animated: true)
                   }),
            Action(title: "Sign Out",
                   image: UIImage(systemName: "rectangle.portrait.and.arrow.right.fill"),
                   handler: { [weak self] in
                       guard let self = self, let window = self.view.window else { return }
                       self.dismiss(animated: true)
                       let loginVC = LogInScreenBuilder.create()
                       let navigationController = UINavigationController(rootViewController: loginVC)
                       UserService.shared.clearCurrentUserFromKeychain()
                       window.rootViewController = navigationController
                   })
        ])
        menuVC.popoverPresentationController?.sourceView = editProfileButton
        menuVC.popoverPresentationController?.sourceRect = editProfileButton.bounds
        present(menuVC, animated: true, completion: nil)
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
    
    private func setupViews() {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 268))
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
        customView.addSubview(postsLabel)
        view.addSubview(tableView)
        
        headerView.addSubview(customView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            customView.topAnchor.constraint(equalTo: headerView.topAnchor),
            customView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            customView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            customView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            
            bannerImage.topAnchor.constraint(equalTo: customView.topAnchor),
            bannerImage.leadingAnchor.constraint(equalTo: customView.leadingAnchor),
            bannerImage.trailingAnchor.constraint(equalTo: customView.trailingAnchor),
            bannerImage.heightAnchor.constraint(equalToConstant: 128),
            
            profileImage.topAnchor.constraint(equalTo: bannerImage.bottomAnchor, constant: -40),
            profileImage.leadingAnchor.constraint(equalTo: customView.leadingAnchor, constant: 8),
            profileImage.heightAnchor.constraint(equalToConstant: 80),
            profileImage.widthAnchor.constraint(equalToConstant: 80),
            
            nameLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: customView.leadingAnchor, constant: 12),
            
            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            usernameLabel.leadingAnchor.constraint(equalTo: customView.leadingAnchor, constant: 12),
            
            followInfoLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 4),
            followInfoLabel.leadingAnchor.constraint(equalTo: customView.leadingAnchor, constant: 12),
            
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
            
            postsLabel.topAnchor.constraint(equalTo: followInfoLabel.bottomAnchor, constant: 12),
            postsLabel.centerXAnchor.constraint(equalTo: customView.centerXAnchor)
        ])
        tableView.tableHeaderView = headerView
    }
    
    private func selectImage() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        showLoading()
        present(imagePickerController, animated: true) { [weak self] in
            guard let self = self else { return }
            hideLoading()
        }
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let postView = PostScreenBuilder.create(postID: posts[indexPath.row].id, user: UserService.shared.currentUser!)
        self.navigationController?.pushViewController(postView, animated: true)
    }
}

extension ProfileViewController: ProfileViewModelDelegate {
    func didChangeBannerPicture(success: Bool) {
        hideLoading()
        if success {
            showMessage(title: "Banner picture changed successfully!") { [weak self] in
                guard let self = self else { return }
                self.bannerImage.kf.setImage(with: URL(string: UserService.shared.currentUser!.bannerImageURL))
            }
        }
    }
    
    func didChangeProfilePicture(success: Bool) {
        hideLoading()
        if success {
            showMessage(title: "Profile picture changed successfully!") { [weak self] in
                guard let self = self else { return }
                self.profileImage.kf.setImage(with: URL(string: UserService.shared.currentUser!.profileImageURL))
                self.dismiss(animated: true)
            }
        }
    }
    
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
    
    func didTapLikeButton(postID: String) {
        let likedPostIndex = posts.firstIndex { post in
            post.id == postID
        }
        guard let likedPostIndex = likedPostIndex else { return }
        posts[likedPostIndex].likes.append(UserService.shared.currentUser!.uid)
        viewModel.didLikePost(postID: postID)
        likeSyncDelegate?.likedPost(postID: postID)
        tableView.reloadRows(at: [IndexPath(row: likedPostIndex, section: 0)], with: .none)
    }
    
    func didTapUnlikeButton(postID: String) {
        let unlikedPostIndex = posts.firstIndex { post in
            post.id == postID
        }
        guard let unlikedPostIndex = unlikedPostIndex else { return }
        if let index = posts[unlikedPostIndex].likes.firstIndex(of: UserService.shared.currentUser!.uid) {
            posts[unlikedPostIndex].likes.remove(at: index)
            viewModel.didUnlikePost(postID: postID)
            likeSyncDelegate?.unlikedPost(postID: postID)
            tableView.reloadRows(at: [IndexPath(row: unlikedPostIndex, section: 0)], with: .none)
        }
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            if isSelectingProfileImage {
                viewModel.changeProfilePicture(imageData: selectedImage.jpegData(compressionQuality: 0.8))
            } else {
                viewModel.changeBannerPicture(imageData: selectedImage.jpegData(compressionQuality: 0.8))
            }
        }
        picker.dismiss(animated: true, completion: nil)
        showLoading()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
