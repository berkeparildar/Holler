//
//  PostViewController.swift
//  Holler
//
//  Created by Berke Parıldar on 3.06.2024.
//

import UIKit


protocol PostViewModelDelegate: AnyObject {
    func didFetchPosts(posts: [Post])
}

class PostViewController: UIViewController {
    
    var viewModel: PostViewModel!
    var replies: [Post] = []
    weak var likeSyncDelegate: LikeSyncDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        viewModel.fetchReplies()
    }
    
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
    
    func setupViews() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension PostViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            1
        } else {
            replies.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let post = viewModel.post
            if post.hasImage {
                let cell = tableView.dequeueReusableCell(withIdentifier: "postImageCell", for: indexPath) as! PostImageCell
                cell.configure(post: post)
                cell.delegate = self
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostCell
            cell.configure(post: post)
            cell.delegate = self
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
}

extension PostViewController: PostViewModelDelegate {
    func didFetchPosts(posts: [Post]) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.replies = posts
            self.tableView.reloadData()
        }
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
        if likeSyncDelegate == nil {
            navigationController?.popToRootViewController(animated: true)
        } else {
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
}
