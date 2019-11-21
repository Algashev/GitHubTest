//
//  ReposTableViewController.swift
//  GitHubTest
//
//  Created by Александр Алгашев on 20.11.2019.
//  Copyright © 2019 Александр Алгашев. All rights reserved.
//

import UIKit
import RealmSwift

class ReposTableViewController: UITableViewController {
    private var repos: Results<RepoRealm>?
    private var reposToken: NotificationToken?
    private let networkService = NetworkService()
    private var isNextPageDownloadEnabled = false
    private var pageNumber = 1

    override func viewDidLoad() {
        super.viewDidLoad()

        self.repos = RepoRealm.all()
        self.refreshControl?.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        self.refresh(nil)
        self.tableView.estimatedRowHeight = 92.5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reposToken = self.repos?.observe({ [weak tableView] changes in
            guard let tableView = tableView else { return }
            switch changes {
            case .initial:
                tableView.reloadData()
            case .update(_, deletions: let deletions,
                         insertions: let insertions,
                         modifications: let modifications):
                tableView.applyChanges(deletions: deletions,
                                       insertions: insertions,
                                       updates: modifications)
            case .error: break
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.reposToken?.invalidate()
    }
    
    private func getReposFromNetwork(pageNumber: Int = 1) {
        networkService.getReposFromNetwork(pageNumber: pageNumber) { (repos) in
            RepoRealm.saveRepos(repos)
        }
    }
    
    @objc private func refresh(_ sender: UIRefreshControl?) {
        networkService.getReposFromNetwork { [weak self] (repos) in
            RepoRealm.delete(self?.repos)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self?.pageNumber = 1
                RepoRealm.saveRepos(repos)
                self?.refreshControl?.endRefreshing()
                self?.isNextPageDownloadEnabled = true
            }
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !self.isNextPageDownloadEnabled { return }
        if self.tableView.isGreaterOrEqualThanMaxOffset {
            self.pageNumber += 1
            self.getReposFromNetwork(pageNumber: self.pageNumber)
            self.isNextPageDownloadEnabled = false
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.repos?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as? RepoCell else { return UITableViewCell() }

        cell.repoNameLabel?.text = self.repos?[indexPath.row].name
        cell.ownerLabel?.text = self.repos?[indexPath.row].owner
        if let watchers = self.repos?[indexPath.row].watchers {
            cell.watchersLabel?.text = "\(watchers)"
        } else {
            cell.watchersLabel?.text = ""
        }
        cell.descriptionLabel?.text = self.repos?[indexPath.row].desc

        return cell
    }

    
}
