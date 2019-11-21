//
//  NetworkService.swift
//  GitHubTest
//
//  Created by Александр Алгашев on 20.11.2019.
//  Copyright © 2019 Александр Алгашев. All rights reserved.
//

import UIKit

class NetworkService {
    private let sharedSession = URLSession.shared
    private var dataTask: URLSessionDataTask?
    private let url = "https://api.github.com/search/repositories?q=language:swift&sort=stars&order=desc&per_page=20&page="
    
    func getReposFromNetwork(pageNumber: Int = 1, completion: @escaping (Repos) -> ()) {
        self.dataTask?.cancel()
        guard let url = URL(string: url+"\(pageNumber)") else { return }
        dataTask = self.sharedSession.dataTask(with: url) { [weak self] data, response, error in
            defer {
                self?.dataTask = nil
            }
            
            if let error = error {
                print(error)
            } else if
                let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                do {
                    let decoder = JSONDecoder()
                    let repos = try decoder.decode(Repos.self, from: data)
                    DispatchQueue.main.async {
                        completion(repos)
                    }
                } catch {
                    print(error)
                    return
                }
            }
        }
        dataTask?.resume()
    }
}
