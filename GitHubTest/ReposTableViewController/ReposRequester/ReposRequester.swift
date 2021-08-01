//
//  ReposRequester.swift
//  GitHubTest
//
//  Created by Александр Алгашев on 30.07.2021.
//  Copyright © 2021 Александр Алгашев. All rights reserved.
//

import Foundation
import Networker

protocol ReposRequesterDelegate: AnyObject {
    func didRecieve(repos: Repos)
    func requestDidFail(error: Error)
    
    
}

class ReposRequester {
    private var isRequestActive = false
    private var page = 1
    private var url: URL {
        ReposSource(page: self.page).url
    }
    private weak var delegate: ReposRequesterDelegate?
    
    init(delegate: ReposRequesterDelegate?) {
        self.delegate = delegate
    }
    
    func reloadData() {
        self.page = 1
        self.loadNextPage()
    }
    
    func loadNextPage() {
        guard !self.isRequestActive else { return }
        self.isRequestActive = true
        HTTPURLRequest(url: self.url).dataTask(decoding: Repos.self, dispatchQueue: .main) { [weak self] response in
            self?.isRequestActive = false
            switch response {
            case .success(let result):
                self?.page += 1
                self?.delegate?.didRecieve(repos: result.decoded)
            case let .failure(error):
                self?.delegate?.requestDidFail(error: error)
            }
        }
    }
    
    
}
