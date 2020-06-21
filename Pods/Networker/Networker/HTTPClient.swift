//
//  HTTPClient.swift
//  Networker
//
//  Created by Александр Алгашев on 25.05.2020.
//  Copyright © 2020 Александр Алгашев. All rights reserved.
//

import Foundation

enum HTTPError: Error, LocalizedError, Equatable {
    case emptyData
    case unknownResponse
    case wrongStatusCode(_ statusCode: String, error: String)
    
    var errorDescription: String? {
        switch self {
        case .emptyData:
            let key = "В ответе сервера отсутствуют данные"
            return NSLocalizedString(key, comment: "Нет данных")
        case .unknownResponse:
            let key = "Ответ сервера не распознан"
            return NSLocalizedString(key, comment: "Ответ не распознан")
        case .wrongStatusCode(let statusCode, let error):
            let key = "Неуспешный ответ состояния HTTP: \(statusCode). Ошибка: \(error)"
            return NSLocalizedString(key, comment: statusCode)
        }
    }
}

class HTTPClient {
    typealias httpResult = (Result<(data: Data, statusCode: String), Error>) -> Void
    
    let session: URLSession
    
    init(_ session: URLSession) {
        self.session = session
    }

    func dataTask(with request: URLRequest, completion: @escaping httpResult) {
        let task = self.session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                let error = HTTPError.emptyData
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                let error = HTTPError.unknownResponse
                completion(.failure(error))
                return
            }
            
            if (200...299).contains(httpResponse.statusCode) {
                let success = (data: data, statusCode: httpResponse.localizedStatusCode)
                completion(.success(success))
            } else {
                let message = String(decoding: data, as: UTF8.self)
                let error = HTTPError.wrongStatusCode(httpResponse.localizedStatusCode, error: message)
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
