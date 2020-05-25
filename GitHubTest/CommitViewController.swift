//
//  CommitViewController.swift
//  GitHubTest
//
//  Created by Александр Алгашев on 21.11.2019.
//  Copyright © 2019 Александр Алгашев. All rights reserved.
//

import UIKit

class CommitViewController: UIViewController {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var shaLabel: UILabel!
    @IBOutlet weak var commitLabel: UILabel!
    @IBOutlet weak var branchLabel: UILabel!
    
    var url = ""
    let commitURLSuffix = "?&per_page=1&page=1"
    let branchURLSuffix = "/branches-where-head"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        guard let url = URL(string: self.url + commitURLSuffix) else { return }
        NetworkService().getFromNetwork(url: url) { [weak self] (commits: [Commit]) in
            guard
                let commit = commits.first,
                let request =
                self?.branchRequestForCommitWith(sha: commit.sha),
                let url = URL(string: commit.author.avatar_url)
            else { return }
            if let image = UIImage(fromPngFileWithName: commit.author.login) {
                self?.avatarImageView.image = image
            } else {
                NetworkService().getImageFromNetwork(url: url) { (image) in
                    self?.avatarImageView.image = image
                    image?.safeAsPngWith(name: commit.author.login)
                }
            }
            NetworkService().getArrayFromNetwork(request: request) { (branches: [Branch]) in
                guard let commit = CommitRealm.add(commits: commits, branches: branches)
                    else { return }
                self?.configureViewWith(commit)
            }
        }
    }
    
    private func configureViewWith(_ commit: CommitRealm) {
        self.authorLabel.text = "Author: \(commit.author)"
        self.shaLabel.text = "Sha: \(commit.sha)"
        self.commitLabel.text = "Commit: \(commit.commit)"
        self.branchLabel.text = "Branch: \(commit.branch)"
    }
    
    private func branchRequestForCommitWith(sha: String?) -> URLRequest? {
        guard let url = URL(string: self.branchURLForCommitWith(sha: sha))
        else { return nil }
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github.groot-preview+json", forHTTPHeaderField: "Accept")
        return request
    }
    
    private func branchURLForCommitWith(sha: String?) -> String {
        return self.url + "/\(sha ?? "")" + self.branchURLSuffix
    }
}
