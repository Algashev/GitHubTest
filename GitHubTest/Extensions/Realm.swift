//
//  Realm.swift
//  GitHubTest
//
//  Created by Александр Алгашев on 17.11.2019.
//  Copyright © 2019 Ray Wenderlich. All rights reserved.
//

import RealmSwift

extension Realm {
    static var parentDirectory: String {
        let realm = try? Realm()
        let path = realm?.configuration.fileURL?.deletingLastPathComponent().path
        if let parentDirectory = path {
            return parentDirectory
        }
        return "Can't get Realm parent directory"
    }
}
