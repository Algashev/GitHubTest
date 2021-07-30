//
//  RepositoriesRequester.swift
//  GitHubTest
//
//  Created by Александр Алгашев on 30.07.2021.
//  Copyright © 2021 Александр Алгашев. All rights reserved.
//

import Foundation
import Networker

protocol RepositoriesRequesterDelegate: AnyObject {
    func didRecieve(repos: Repos)
    func requestDidFail(error: Error)
    
    
}

class RepositoriesRequester {
    private var isNextPageDownloadEnabled = true
    private var pageNumber = 1
    private var url: URL {
        RepositoriesSource(page: self.pageNumber).url
    }
    weak var delegate: RepositoriesRequesterDelegate?
    
    func reloadData() {
        self.pageNumber = 1
        self.loadNextPage()
    }
    
    func loadNextPage() {
        guard self.isNextPageDownloadEnabled else { return }
        self.isNextPageDownloadEnabled = false
        HTTPURLRequest(url: self.url).dataTask(decoding: Repos.self, dispatchQueue: .main) { [weak self] response in
            self?.isNextPageDownloadEnabled = true
            switch response {
            case .success(let result):
                self?.pageNumber += 1
                self?.delegate?.didRecieve(repos: result.decoded)
            case let .failure(error):
                self?.delegate?.requestDidFail(error: error)
            }
        }
    }
    
    
}
