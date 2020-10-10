//
//  HTTPClient.swift
//  Networker
//
//  Created by Александр Алгашев on 25.05.2020.
//  Copyright © 2020 Александр Алгашев. All rights reserved.
//

import Foundation

class HTTPClient {
    enum Error: Swift.Error {
        case emptyData
        case unknownResponse
        case wrongStatusCode(_ httpData: HTTPData)
    }
    
    typealias Result = Swift.Result<HTTPData, Swift.Error>
    typealias Completion = (Result) -> Void
    
    let session: URLSession
    
    init(_ session: URLSession) {
        self.session = session
    }

    func dataTask(with request: URLRequest, completion: @escaping Completion) {
        let task = self.session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                let error = Error.emptyData
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                let error = Error.unknownResponse
                completion(.failure(error))
                return
            }
            
            let httpData = HTTPData(data: data, response: httpResponse)
            if (200...299).contains(httpResponse.statusCode) {
                completion(.success(httpData))
            } else {
                let error = Error.wrongStatusCode(httpData)
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}

extension HTTPClient.Error: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .emptyData:
            let key = "В ответе сервера отсутствуют данные"
            return NSLocalizedString(key, comment: "Нет данных")
        case .unknownResponse:
            let key = "Ответ сервера не распознан"
            return NSLocalizedString(key, comment: "Ответ не распознан")
        case .wrongStatusCode(let httpData):
            let statusCode = httpData.response.localizedStatusCode
            let error = httpData.data.utf8String
            let key = "Неуспешный ответ состояния HTTP: \(statusCode). Ошибка: \(error)"
            return NSLocalizedString(key, comment: statusCode)
        }
    }
}
