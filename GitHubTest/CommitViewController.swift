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
    
    var path = ""
    let commitURLSuffix = "?&per_page=1&page=1"
    let branchURLSuffix = "/branches-where-head"
    
    static func create(repo: RLMRepo?) -> CommitViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "\(CommitViewController.self)")
        guard let commitViewController = controller as? CommitViewController,
              let repo = repo
        else { return nil }
        
        commitViewController.path = CommitViewController.commitURL(owner: repo.owner, repo: repo.name)
        
        return commitViewController
    }
    
    static private func commitURL(owner: String, repo: String) -> String {
        return "https://api.github.com/repos/\(owner)/\(repo)/commits"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        guard let request = try? HTTPURLRequest(path: self.path + self.commitURLSuffix)
        else { return }
        request.dataTask(decoding: [Commit].self, dispatchQueue: .main) { [weak self] response in
            switch response {
            case let .success(result):
                let commits = result.decoded
                guard
                    let commit = commits.first,
                    let urlRequest =
                    self?.branchRequestForCommit(with: commit.sha)
                else { return }
                if let image = UIImage(fromPngFileWithName: commit.author.login) {
                    self?.avatarImageView.image = image
                } else {
                    guard let request = try? HTTPURLRequest(path: commit.author.avatar_url)
                    else { return }
                    request.imageDataTask(dispatchQueue: .main) { response in
                        switch response {
                        case .success(let result):
                            let image = result.image
                            self?.avatarImageView.image = image
                            image.safeAsPngWith(name: commit.author.login)
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                    }
                }
                let request = HTTPURLRequest(request: urlRequest)
                request.dataTask(decoding: [Branch].self) { response in
                    switch response {
                    case .success(let results):
                        let branches = results.decoded
                        DispatchQueue.main.async {
                            guard let commit = RLMCommit.add(commits: commits, branches: branches)
                            else { return }
                            self?.updateView(with: commit)
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func updateView(with commit: RLMCommit) {
        self.authorLabel.text = "Author: \(commit.author)"
        self.shaLabel.text = "Sha: \(commit.sha)"
        self.commitLabel.text = "Commit: \(commit.commit)"
        self.branchLabel.text = "Branch: \(commit.branch)"
    }
    
    private func branchRequestForCommit(with sha: String?) -> URLRequest? {
        guard let url = URL(string: self.branchURLForCommitWith(sha: sha))
        else { return nil }
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github.groot-preview+json", forHTTPHeaderField: "Accept")
        return request
    }
    
    private func branchURLForCommitWith(sha: String?) -> String {
        return self.path + "/\(sha ?? "")" + self.branchURLSuffix
    }
}
