//
//  RepoRealm.swift
//  GitHubTest
//
//  Created by Александр Алгашев on 20.11.2019.
//  Copyright © 2019 Александр Алгашев. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers class RepoRealm: Object {
    enum Property: String {
        case id, name, desc, owner, watchers
    }
    
    dynamic var id = 0
    dynamic var name = ""
    dynamic var desc = ""
    dynamic var owner = ""
    dynamic var watchers = 0
    
    override static func primaryKey() -> String? {
        return RepoRealm.Property.id.rawValue
    }
    
    convenience init(_ repo: Repo) {
        self.init()
        self.id = repo.id
        self.name = repo.name
        self.desc = repo.description
        self.owner = repo.owner.login
        self.watchers = repo.watchers
    }
}

extension RepoRealm {
    static func all() -> Results<RepoRealm>? {
        let realm = try? Realm()
        return realm?.objects(RepoRealm.self).sorted(byKeyPath: RepoRealm.Property.watchers.rawValue, ascending: false)
    }
    
    static func saveRepos(_ repos: Repos) {
        let realm = try? Realm()
        try? realm?.write {
            repos.items.forEach {
                realm?.add(RepoRealm($0))
            }
        }
    }
    
    static func delete(_ repos: Results<RepoRealm>?) {
        guard let repos = repos else { return }
        repos.forEach {
            $0.delete()
        }
    }
    
    func delete() {
        try? self.realm?.write {
            self.realm?.delete(self)
        }
    }
}
