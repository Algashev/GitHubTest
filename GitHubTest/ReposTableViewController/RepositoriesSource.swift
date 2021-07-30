//
//  RepositoriesSource.swift
//  GitHubTest
//
//  Created by Александр Алгашев on 30.07.2021.
//  Copyright © 2021 Александр Алгашев. All rights reserved.
//

import Foundation

struct RepositoriesSource {
    private let githubURL = "https://api.github.com/search/repositories"
    private let language = "language:swift"
    private let sort = "stars"
    private let order = "desc"
    private let perPage = 20
    private(set) var url: URL?
    
    init(page: Int) {
        var components = URLComponents(string: self.githubURL)
        components?.queryItems = self.query(page: page)
        self.url = components?.url
    }
    
    private func query(page: Int) -> [URLQueryItem] {
        [
            URLQueryItem(name: "q", value: self.language),
            URLQueryItem(name: "sort", value: self.sort),
            URLQueryItem(name: "order", value: self.order),
            URLQueryItem(name: "per_page", value: self.perPage.string),
            URLQueryItem(name: "page", value: page.string)
        ]
    }
    
    
}
