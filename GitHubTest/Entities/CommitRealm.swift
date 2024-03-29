//
//  RLMCommit.swift
//  GitHubTest
//
//  Created by Александр Алгашев on 21.11.2019.
//  Copyright © 2019 Александр Алгашев. All rights reserved.
//

import RealmSwift

@objcMembers class RLMCommit: Object {
    enum Property: String {
        case sha, author, commit, branch, avatar, avatarLocal
    }
    
    dynamic var sha = ""
    dynamic var author = ""
    dynamic var commit = ""
    dynamic var branch = ""
    dynamic var avatar = ""
    dynamic var avatarLocal = ""
    
    override static func primaryKey() -> String? {
        Property.sha.rawValue
    }
    
    convenience init(commit: Commit, branch: Branch) {
        self.init()
        self.sha = commit.sha
        self.author = commit.author.login
        self.commit = commit.commit.message
        self.branch = branch.name
        self.avatar = commit.author.avatar_url
    }
}

extension RLMCommit {
    private static func withSHA(_ sha: String) -> RLMCommit? {
        let realm = try? Realm()
        return realm?.objects(RLMCommit.self).filter("\(RLMCommit.Property.sha.rawValue) = '\(sha)'").first
    }
    
    static func add(commits: [Commit], branches: [Branch]) -> RLMCommit? {
        guard
            let commit = commits.first,
            let branch = branches.first,
            let realm = try? Realm()
        else { return nil }
        let commitRealm = RLMCommit(commit: commit, branch: branch)
        try? realm.write {
            if RLMCommit.withSHA(commitRealm.sha) != nil {
                realm.create(RLMCommit.self, value: commitRealm, update: .all)
            } else {
                realm.add(commitRealm)
            }
        }
        return commitRealm
    }
}
