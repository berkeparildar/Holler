//
//  PostViewController.swift
//  Holler
//
//  Created by Berke Parıldar on 3.06.2024.
//

import UIKit

final class PostViewController: UIViewController {
    
    var viewModel: PostViewModel!
    var replies: [Post] = []
    weak var likeSyncDelegate: LikeSyncDelegate?
    weak var replySyncDelegate: ReplySyncDelegate?
    
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
    
    private lazy var replyToPostButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "text.bubble"), for: .normal)
        button.tintColor = .black
        button.backgroundColor = .white
        button.layer.cornerRadius = 18
        button.addTarget(self, action: #selector(didTapReplyButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let noRepliesLabel: UILabel = {
        let label = UILabel()
        label.text = "There are no replies yet.."
        label.textColor = .gray
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        viewModel.fetchReplies()
    }
    
    private func setupViews() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        view.addSubview(replyToPostButton)
        NSLayoutConstraint.activate([
            replyToPostButton.heightAnchor.constraint(equalToConstant: 36),
            replyToPostButton.widthAnchor.constraint(equalToConstant: 36),
            replyToPostButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            replyToPostButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        
        view.addSubview(noRepliesLabel)
        NSLayoutConstraint.activate([
            noRepliesLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noRepliesLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 200)
        ])
    }
    
    @objc func didTapReplyButton() {
        present(PostCreateScreenBuilder.create(delegate: self, rootPostID: viewModel.post.id), animated: true)
    }
}

extension PostViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if let post = viewModel.post, let user = post.user {
                self.title = "\(user.name)'s Post"
                return 1
            }
            return 0
        } else {
            return replies.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let post = viewModel.post else { return UITableViewCell() }
            if post.hasImage {
                let cell = tableView.dequeueReusableCell(withIdentifier: "postImageCell", for: indexPath) as! PostImageCell
                cell.configure(post: post)
                cell.delegate = self
                cell.enableReplies()
                cell.separatorInset = UIEdgeInsets(top: 0, left: self.view.frame.width, bottom: 0, right: 0)
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostCell
            cell.configure(post: post)
            cell.delegate = self
            cell.enableReplies()
            cell.separatorInset = UIEdgeInsets(top: 0, left: self.view.frame.width, bottom: 0, right: 0)
            return cell
        }
        let post = replies[indexPath.row]
        if post.hasImage {
            let cell = tableView.dequeueReusableCell(withIdentifier: "postImageCell", for: indexPath) as! PostImageCell
            cell.configure(post: post)
            cell.delegate = self
            cell.disableReplies()
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostCell
        cell.configure(post: post)
        cell.delegate = self
        cell.disableReplies()
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let headerView = UIView()
            headerView.backgroundColor = .black
            let headerLabel = UILabel()
            headerLabel.text = "Replies"
            headerLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
            headerLabel.textColor = .white
            headerLabel.translatesAutoresizingMaskIntoConstraints = false
            headerView.addSubview(headerLabel)
            NSLayoutConstraint.activate([
                headerLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
                headerLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
                headerLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
                headerLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
            ])
            return headerView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 1 && !self.replies.isEmpty ? 40 : 0
    }
}

extension PostViewController: PostViewModelDelegate {
    func didFetchPosts(posts: [Post]) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.replies = posts.sorted(by: { $0.likes.count > $1.likes.count })
            self.noRepliesLabel.isHidden = !self.replies.isEmpty
            self.tableView.reloadData()
        }
    }
}

extension PostViewController: PostCreationDelegate {
    func didPost(postID: String) {
        replySyncDelegate?.repliedToPost(postID: postID, rootPostID: viewModel.post.id)
        viewModel.fetchReplies()
    }
}

extension PostViewController: CellDelegate {
    func didTapLikeButton(postID: String) {
        if postID == viewModel.post.id {
            likeSyncDelegate?.likedPost(postID: postID)
            viewModel.post.likes.append(UserService.shared.currentUser!.uid)
            viewModel.didLikePost(postID: postID)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
            }
        } else {
            let postIndex = replies.firstIndex(where: { $0.id == postID})!
            replies[postIndex].likes.append(UserService.shared.currentUser!.uid)
            viewModel.didLikePost(postID: postID)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                tableView.reloadRows(at: [IndexPath(row: postIndex, section: 1)], with: .none)
            }
        }
    }
    
    func didTapUnlikeButton(postID: String) {
        if postID == viewModel.post.id {
            likeSyncDelegate?.unlikedPost(postID: postID)
            viewModel.post.likes.remove(at: viewModel.post.likes.firstIndex(where: { $0 == UserService.shared.currentUser!.uid })!)
            viewModel.didUnlikePost(postID: postID)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
            }
        } else {
            let postIndex = replies.firstIndex(where: { $0.id == postID})!
            replies[postIndex].likes.remove(at: replies[postIndex].likes.firstIndex(where: { $0 == UserService.shared.currentUser!.uid })!)
            viewModel.didUnlikePost(postID: postID)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                tableView.reloadRows(at: [IndexPath(row: postIndex, section: 1)], with: .none)
            }
        }
    }
    
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
}
