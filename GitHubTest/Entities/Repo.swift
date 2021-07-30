//
//  Repo.swift
//  GitHubTest
//
//  Created by Александр Алгашев on 19.11.2019.
//  Copyright © 2019 Александр Алгашев. All rights reserved.
//

import Foundation

struct Repos: Codable {
    let items: [Repo]
}

struct Repo: Codable {
    let id: Int
    let name: String
    let description: String?
    let owner: Owner
    let watchers: Int
}

struct Owner: Codable {
    let login: String
}
