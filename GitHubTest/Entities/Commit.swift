//
//  Commit.swift
//  GitHubTest
//
//  Created by Александр Алгашев on 21.11.2019.
//  Copyright © 2019 Александр Алгашев. All rights reserved.
//

import Foundation

struct Commit: Codable {
    let sha: String
    let commit: CommitName
    let author: Author
}

struct CommitName: Codable {
    let message: String
}

struct Author: Codable {
    let login: String
    let avatar_url: String
}

struct Branch: Codable {
    let name: String
}
