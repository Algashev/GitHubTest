//
//  RLMRepo.swift
//  GitHubTest
//
//  Created by Александр Алгашев on 20.11.2019.
//  Copyright © 2019 Александр Алгашев. All rights reserved.
//

import RealmSwift

@objcMembers class RLMRepo: Object {
    enum Property: String {
        case id, name, desc, owner, watchers
    }
    
    dynamic var id = 0
    dynamic var name = ""
    dynamic var desc = ""
    dynamic var owner = ""
    dynamic var watchers = 0
    
    override static func primaryKey() -> String? {
        Property.id.rawValue
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

extension RLMRepo {
    static func all() -> Results<RLMRepo>? {
        let realm = try? Realm()
        return realm?.objects(RLMRepo.self).sorted(byKeyPath: RLMRepo.Property.watchers.rawValue, ascending: false)
    }
    
    static func saveRepos(_ repos: Repos) {
        let realm = try? Realm()
        try? realm?.write {
            repos.items.forEach {
                realm?.add(RLMRepo($0))
            }
        }
    }
    
    static func delete(_ repos: Results<RLMRepo>?) {
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
