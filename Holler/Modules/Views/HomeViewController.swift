//
//  HomeViewController.swift
//  Holler
//
//  Created by Berke Parıldar on 15.05.2024.
//

import UIKit

final class HomeViewController: UIViewController {
    
    var viewModel: HomeViewModel!
    var posts: [Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showLoading()
        setupViews()
        viewModel.fetchPostsForHomePage()
    }
    
    private lazy var createPostButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .black
        button.backgroundColor = .white
        button.layer.cornerRadius = 18
        button.addTarget(self, action: #selector(didTapCreatePostButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(PostCell.self, forCellReuseIdentifier: "postCell")
        tableView.delaysContentTouches = false
        tableView.register(PostImageCell.self, forCellReuseIdentifier: "postImageCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
        return refreshControl
    }()
    
    private lazy var progressView: UIActivityIndicatorView = {
        let progressView = UIActivityIndicatorView()
        progressView.isHidden = true
        progressView.translatesAutoresizingMaskIntoConstraints = false
        return progressView
    }()
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "There is nothing here... Create a post or try following a user"
        label.textColor = .gray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    func setupViews() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        view.addSubview(createPostButton)
        NSLayoutConstraint.activate([
            createPostButton.heightAnchor.constraint(equalToConstant: 36),
            createPostButton.widthAnchor.constraint(equalToConstant: 36),
            createPostButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            createPostButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        view.addSubview(progressView)
        NSLayoutConstraint.activate([
            progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 32),
            progressView.widthAnchor.constraint(equalToConstant: 32)
        ])
        view.addSubview(emptyStateLabel)
        NSLayoutConstraint.activate([
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    @objc private func refreshData() {
        viewModel.fetchPostsForHomePage()
    }
    
    @objc func didTapCreatePostButton() {
        present(PostCreateScreenBuilder.create(delegate: self), animated: true)
    }
    
    private func showLoading() {
        tableView.isHidden = true
        progressView.isHidden = false
        progressView.startAnimating()
    }
    
    private func hideLoading() {
        progressView.stopAnimating()
        progressView.isHidden = true
        tableView.isHidden = false
    }
    
    private func updateEmptyStateLabel() {
        emptyStateLabel.isHidden = !posts.isEmpty
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.row]
        if post.hasImage {
            let cell = tableView.dequeueReusableCell(withIdentifier: "postImageCell", for: indexPath) as! PostImageCell
            cell.delegate = self
            cell.configure(post: posts[indexPath.row])
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostCell
        cell.delegate = self
        cell.configure(post: posts[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let postView = PostScreenBuilder.create(postID: posts[indexPath.row].id, user: posts[indexPath.row].user!,  likeDelegate: self, replyDelegate: self)
        self.navigationController?.pushViewController(postView, animated: true)
    }
}

extension HomeViewController: PostCreationDelegate {
    func didPost(postID: String) {
        showLoading()
        posts.removeAll()
        viewModel.fetchPostsForHomePage()
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            tableView.reloadData()
        }
    }
}

extension HomeViewController: HomeViewModelDelegate {
    func didFetchPosts(posts: [Post]) {
        self.posts = posts.sorted(by: { $0.time > $1.time })
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self = self else { return }
            refreshControl.endRefreshing()
            tableView.reloadData()
            hideLoading()
            updateEmptyStateLabel()
        }
    }
}

extension HomeViewController: CellDelegate {
    func didTapUserProfile(userID: String, user: User?) {
        if userID == UserService.shared.currentUser!.uid {
            guard let tabBarController = self.tabBarController else { return }
            UIView.transition(with: tabBarController.view, duration: 0.3, options: .transitionCrossDissolve, animations: {
                tabBarController.selectedIndex = 2
            }, completion: nil)
        } else {
            let profileView = ProfileScreenBuilder.create(userID: userID, user: user)
            self.navigationController?.pushViewController(profileView, animated: true)
        }
    }
    
    func didTapLikeButton(postID: String) {
        let likedPostIndex = posts.firstIndex { post in
            post.id == postID
        }
        guard let likedPostIndex = likedPostIndex else { return }
        posts[likedPostIndex].likes.append(UserService.shared.currentUser!.uid)
        viewModel.didLikePost(postID: postID)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            tableView.reloadRows(at: [IndexPath(row: likedPostIndex, section: 0)], with: .none)
        }
    }
    
    func didTapUnlikeButton(postID: String) {
        let unlikedPostIndex = posts.firstIndex { post in
            post.id == postID
        }
        guard let unlikedPostIndex = unlikedPostIndex else { return }
        if let index = posts[unlikedPostIndex].likes.firstIndex(of: UserService.shared.currentUser!.uid) {
            posts[unlikedPostIndex].likes.remove(at: index)
            viewModel.didUnlikePost(postID: postID)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                tableView.reloadRows(at: [IndexPath(row: unlikedPostIndex, section: 0)], with: .none)
            }
        }
    }
}

extension HomeViewController: LikeSyncDelegate {
    func unlikedPost(postID: String) {
        let unlikedPost = posts.firstIndex { post in
            post.id == postID
        }
        if let index = posts[unlikedPost!].likes.firstIndex(of: UserService.shared.currentUser!.uid) {
            posts[unlikedPost!].likes.remove(at: index)
        }
        tableView.reloadData()
    }
    
    func likedPost(postID: String) {
        let likedPost = posts.firstIndex { post in
            post.id == postID
        }
        posts[likedPost!].likes.append(UserService.shared.currentUser!.uid)
        tableView.reloadData()
    }
}

extension HomeViewController: ReplySyncDelegate {
    func repliedToPost(postID: String, rootPostID: String) {
        let repliedPostIndex = posts.firstIndex { post in
            post.id == rootPostID
        }
        guard let repliedPostIndex = repliedPostIndex else { return }
        posts[repliedPostIndex].replies.append(postID)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            tableView.reloadData()
        }
    }
}
