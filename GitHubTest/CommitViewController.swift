//
//  CommitViewController.swift
//  GitHubTest
//
//  Created by Александр Алгашев on 21.11.2019.
//  Copyright © 2019 Александр Алгашев. All rights reserved.
//

import UIKit
import Networker

class CommitViewController: UIViewController {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var shaLabel: UILabel!
    @IBOutlet weak var commitLabel: UILabel!
    @IBOutlet weak var branchLabel: UILabel!
    
    private let networker = Networker(decoder: JSONDecoder())
    var url = ""
    let commitURLSuffix = "?&per_page=1&page=1"
    let branchURLSuffix = "/branches-where-head"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        guard let url = URL(string: self.url + self.commitURLSuffix) else { return }
        self.networker.dataTask(with: url, [Commit].self) { [weak self] (result) in
            switch result {
            case .success(let commits):
                guard
                    let commit = commits.first,
                    let request =
                    self?.branchRequestForCommitWith(sha: commit.sha),
                    let url = URL(string: commit.author.avatar_url)
                else { return }
                if let image = UIImage(fromPngFileWithName: commit.author.login) {
                    self?.avatarImageView.image = image
                } else {
                    self?.networker.fetchImage(with: url) { (result) in
                        switch result {
                        case .success(let image):
                            self?.avatarImageView.image = image
                            image.safeAsPngWith(name: commit.author.login)
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                    }
                }
                self?.networker.dataTask(with: request, [Branch].self) { (result) in
                    switch result {
                    case .success(let branches):
                        guard let commit = RLMCommit.add(commits: commits, branches: branches)
                            else { return }
                        self?.updateView(with: commit)
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            case .failure:
                break
            }
        }
    }
    
    private func updateView(with commit: RLMCommit) {
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
