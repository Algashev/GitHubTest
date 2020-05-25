//
//  Results.swift
//  GitHubTest
//
//  Created by Александр Алгашев on 25.05.2020.
//  Copyright © 2020 Александр Алгашев. All rights reserved.
//

import RealmSwift

extension Results where Element: Object {
    func delete() {
        try? self.realm?.write {
            self.realm?.delete(self)
        }
    }
}
