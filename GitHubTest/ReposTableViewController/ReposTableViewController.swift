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
    private var repositoriesRequester: RepositoriesRequester?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.repos = RLMRepo.all(sorted: .watchers, ascending: false)
        self.refreshControl?.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        self.repositoriesRequester = RepositoriesRequester()
        self.repositoriesRequester?.delegate = self
        self.repositoriesRequester?.loadNextPage()
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
    
    private func getReposFromNetwork(page: Int) {
        guard let url = RepositoriesSource(page: page).url else { return }
        HTTPURLRequest(url: url).dataTask(decoding: Repos.self) { response in
            switch response {
            case let .success(result):
                let repos = result.decoded
                RLMRepo.add(repos)
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }
    
    @objc private func refresh(_ sender: UIRefreshControl?) {
//        guard let url = RepositoriesSource(page: 1).url else { return }
//        HTTPURLRequest(url: url).dataTask(decoding: Repos.self, dispatchQueue: .main) { [weak self] response in
//            switch response {
//            case .success(let result):
//                let repos = result.decoded
//                self?.repos?.delete()
//                self?.removeAvatars()
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                    self?.pageNumber = 1
//                    RLMRepo.add(repos)
//                    self?.refreshControl?.endRefreshing()
//                    self?.isNextPageDownloadEnabled = true
//                }
//            case .failure(let error):
//                print(error.localizedDescription)
//            }
//        }
    }
    
    
    private func removeAvatars() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let avatarsURL = documentsURL.appendingPathComponent("avatars", isDirectory: true)
        try? FileManager.default.removeItem(at: avatarsURL)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.tableView.isGreaterOrEqualThanMaxOffset {
            self.repositoriesRequester?.loadNextPage()
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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard
            let controller = storyboard.instantiateViewController(withIdentifier: "\(CommitViewController.self)") as? CommitViewController,
            let repo = self.repos?[indexPath.row]
        else { return }
        
        controller.path = self.commitURL(owner: repo.owner, repo: repo.name)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    private func commitURL(owner: String, repo: String) -> String {
        return "https://api.github.com/repos/\(owner)/\(repo)/commits"
    }
}

// MARK: - RepositoriesRequesterDelegate

extension ReposTableViewController: RepositoriesRequesterDelegate {
    func didRecieve(repos: Repos) {
        RLMRepo.add(repos)
    }
    
    func requestDidFail(error: Error) {
        let alert = UIAlertController(title: "Ошибка", message: error.localizedDescription, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ок", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true)
    }
    
    
}
