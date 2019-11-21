//
//  CommitRealm.swift
//  GitHubTest
//
//  Created by Александр Алгашев on 21.11.2019.
//  Copyright © 2019 Александр Алгашев. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers class CommitRealm: Object {
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
        return CommitRealm.Property.sha.rawValue
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

extension CommitRealm {
    private static func withSHA(_ sha: String) -> CommitRealm? {
        let realm = try? Realm()
        return realm?.objects(CommitRealm.self).filter("\(CommitRealm.Property.sha.rawValue) = '\(sha)'").first
    }
    
    static func add(commits: [Commit], branches: [Branch]) -> CommitRealm? {
        guard
            let commit = commits.first,
            let branch = branches.first,
            let realm = try? Realm()
        else { return nil }
        let commitRealm = CommitRealm(commit: commit, branch: branch)
        try? realm.write {
            if CommitRealm.withSHA(commitRealm.sha) != nil {
                realm.create(CommitRealm.self, value: commitRealm, update: .all)
            } else {
                realm.add(commitRealm)
            }
        }
        return commitRealm
    }
}
