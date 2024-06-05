//
//  SearchViewController.swift
//  Holler
//
//  Created by Berke Parıldar on 20.05.2024.
//

import UIKit

protocol SearchViewModelDelegate: AnyObject {
    func didFetchUsers(users: [User])
}

class SearchViewController: UIViewController {
    
    var viewModel: SearchViewModel!
    private let searchController = UISearchController(searchResultsController: nil)
    private var searchResults: [User] = []
    
    private var searchDebounceTimer: Timer?
    private let debounceInterval: TimeInterval = 1
    private var isSearchCancelled = false
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        tableView.register(UserCell.self, forCellReuseIdentifier: "cell")
        tableView.estimatedRowHeight = 300
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let informativeLabel: UILabel = {
        let label = UILabel()
        label.text = "Search users with their usernames"
        label.textColor = .gray
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Search"
        view.backgroundColor = .black
        configureSearchController()
        setupTableView()
    }
    
    private func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "@holler"
        searchController.searchBar.autocorrectionType = .no
        searchController.searchBar.autocapitalizationType = .none
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        view.addSubview(informativeLabel)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            informativeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            informativeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -240)
        ])
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        informativeLabel.isHidden = !searchResults.isEmpty
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UserCell
        cell.configure(user: searchResults[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = searchResults[indexPath.row]
        let profileView = ProfileScreenBuilder.create(userID: user.uid, user: user)
        navigationController?.pushViewController(profileView, animated: true)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension SearchViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        informativeLabel.isHidden = !searchText.isEmpty
        searchDebounceTimer?.invalidate()
        searchDebounceTimer = Timer.scheduledTimer(withTimeInterval: debounceInterval, repeats: false) { [weak self] _ in
            guard let self = self, !self.isSearchCancelled else {
                self?.isSearchCancelled = false
                return
            }
            self.viewModel.fetchUser(search: searchText)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearchCancelled = true
        searchResults.removeAll()
        informativeLabel.isHidden = false
        tableView.reloadData()
    }
}

extension SearchViewController: SearchViewModelDelegate {
    func didFetchUsers(users: [User]) {
        searchResults = users
        informativeLabel.isHidden = !searchResults.isEmpty
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
    }
}
