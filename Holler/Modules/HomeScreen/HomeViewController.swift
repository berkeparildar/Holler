//
//  HomeViewController.swift
//  Holler
//
//  Created by Berke Parıldar on 15.05.2024.
//

import UIKit

protocol PostCreationDelegate: AnyObject {
    func didPost()
}

class HomeViewController: UIViewController {
    
    var viewModel: HomeViewModel!
    var posts: [HomePagePost] = []
    
    private lazy var createPostButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.addTarget(self, action: #selector(didTapCreatePostButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(FeedPostCell.self, forCellReuseIdentifier: "postCell")
        tableView.register(FeedPostImageCell.self, forCellReuseIdentifier: "postImageCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var progressView: UIActivityIndicatorView = {
        let progressView = UIActivityIndicatorView()
        progressView.isHidden = true
        progressView.translatesAutoresizingMaskIntoConstraints = false
        return progressView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showLoading()
        setupViews()
        viewModel.fetchPostsForHomePage { [weak self] posts, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching posts for home page: \(error.localizedDescription)")
                return
            }
            self.posts = posts ?? []
            tableView.reloadData()
            hideLoading()
        }
        self.title = "Home"
    }
    
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
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.row]
        if post.hasImage {
            let cell = tableView.dequeueReusableCell(withIdentifier: "postImageCell", for: indexPath) as! FeedPostImageCell
            cell.configure(with: post)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! FeedPostCell
        cell.configure(with: post)
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension HomeViewController: PostCreationDelegate {
    func didPost() {
        showLoading()
        posts.removeAll()
        tableView.reloadData()
        viewModel.fetchPostsForHomePage { [weak self] posts, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching posts for home page: \(error.localizedDescription)")
                return
            }
            self.posts = posts ?? []
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.hideLoading()
            }
        }
    }
}
