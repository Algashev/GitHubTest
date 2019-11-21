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
    
    func getFromNetwork<T: Codable>(url: URL, completion: @escaping (T) -> ()) {
        self.dataTask?.cancel()
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
                    let repos = try decoder.decode(T.self, from: data)
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
    
    func getArrayFromNetwork<T: Codable>(url: URL, completion: @escaping ([T]) -> ()) {
        self.dataTask?.cancel()
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
                    let repos = try decoder.decode([T].self, from: data)
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
    
    func getArrayFromNetwork<T: Codable>(request: URLRequest, completion: @escaping ([T]) -> ()) {
        self.dataTask?.cancel()
        dataTask = self.sharedSession.dataTask(with: request) { [weak self] data, response, error in
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
                    let repos = try decoder.decode([T].self, from: data)
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
    
    func getImageFromNetwork(url: URL, completion: @escaping (UIImage?) -> ()) {
        self.dataTask?.cancel()
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
                DispatchQueue.main.async {
                    completion(UIImage(data: data))
                }
            }
        }
        dataTask?.resume()
    }
}
