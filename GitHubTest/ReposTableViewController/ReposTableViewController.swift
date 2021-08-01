//
//  ReposTableViewController.swift
//  GitHubTest
//
//  Created by Александр Алгашев on 20.11.2019.
//  Copyright © 2019 Александр Алгашев. All rights reserved.
//

import UIKit
import RealmSwift
import Networker

class ReposTableViewController: UITableViewController {
    private var repos: Results<RLMRepo>?
    private var reposToken: NotificationToken?
    private var reposRequester: ReposRequester?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.repos = RLMRepo.all(sorted: .watchers, ascending: false)
        self.refreshControl?.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        self.reposRequester = ReposRequester(delegate: self)
        self.reposRequester?.loadNextPage()
        self.tableView.estimatedRowHeight = 92.5
        print(Realm.parentDirectory)
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
    
    @objc private func refresh(_ sender: UIRefreshControl?) {
        self.repos?.delete()
        self.removeAvatars()
        self.reposRequester?.reloadData()
    }
    
    private func removeAvatars() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let avatarsURL = documentsURL.appendingPathComponent("avatars", isDirectory: true)
        try? FileManager.default.removeItem(at: avatarsURL)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.tableView.isGreaterOrEqualThanMaxOffset {
            self.reposRequester?.loadNextPage()
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.repos?.count ?? 0
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
        cell.infoLabel?.text = self.repos?[indexPath.row].desc

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let commitViewController = CommitViewController.create(repo: self.repos?[indexPath.row]) else { return }
        
        self.navigationController?.pushViewController(commitViewController, animated: true)
    }
    
    
}

// MARK: - ReposRequesterDelegate

extension ReposTableViewController: ReposRequesterDelegate {
    func didRecieve(repos: Repos) {
        self.refreshControl?.endRefreshing()
        RLMRepo.add(repos)
    }
    
    func requestDidFail(error: Error) {
        self.refreshControl?.endRefreshing()
        let alert = UIAlertController(title: "Ошибка", message: error.localizedDescription, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ок", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true)
    }
    
    
}
