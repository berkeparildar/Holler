//
//  HomeViewController.swift
//  Holler
//
//  Created by Berke Parıldar on 15.05.2024.
//

import UIKit

class HomeViewController: UIViewController, LoadingShowable {
    
    var viewModel: HomeViewModel!
    var posts: [HomePagePost] = []
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
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
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! TableViewPostCell
        cell.configureAsHomePost(with: posts[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
