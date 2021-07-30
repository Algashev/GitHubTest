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
    
    override init() {
        super.init()
    }
    
    init(_ repo: Repo) {
        self.id = repo.id
        self.name = repo.name
        self.desc = repo.description
        self.owner = repo.owner.login
        self.watchers = repo.watchers
    }
}

extension RLMRepo {
    static func all(
        sorted keyPath: Property? = nil,
        ascending: Bool = true) -> Results<RLMRepo>?
    {
        let realm = try? Realm()
        let repos = realm?.objects(RLMRepo.self)
        guard let keyPath = keyPath else { return repos }
        let sortedRepos = repos?.sorted(byKeyPath: keyPath.rawValue, ascending: ascending)
        return sortedRepos
    }
    
    static func add(_ repos: Repos) {
        let realm = try? Realm()
        try? realm?.write {
            repos.items.forEach {
                realm?.add(RLMRepo($0))
            }
        }
    }
}
