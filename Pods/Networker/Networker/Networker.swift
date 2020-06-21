//
//  Networker.swift
//  Networker
//
//  Created by Александр Алгашев on 14.05.2020.
//  Copyright © 2020 Александр Алгашев. All rights reserved.
//

import UIKit

let module = NSStringFromClass(Networker.self).components(separatedBy:".")[0]

public typealias NWJSONResult<T: Decodable> = (Result<T, Error>) -> Void
public typealias NWImageResult = (Result<UIImage, Error>) -> Void

public final class Networker {
    public enum Error: Swift.Error, LocalizedError {
        case invalidImageData
        
        public var errorDescription: String? {
            switch self {
            case .invalidImageData:
                let key = "Не удалось создать изображение из полученных данных"
                let comment = "Неверный формат данных изображения"
                return NSLocalizedString(key, comment: comment)
            }
        }
    }
    
    public var decoder = JSONDecoder()
    
    public init() { }
    
    public init(decoder: JSONDecoder) {
        self.decoder = decoder
    }
    
    public func dataTask<T: Decodable>(with url: URL, _ type: T.Type, completion: @escaping NWJSONResult<T>) {
        let request = URLRequest(url: url)
        self.dataTask(with: request, T.self) { (result) in
            completion(result)
        }
    }
    
    public func dataTask<T: Decodable>(with request: URLRequest, _ type: T.Type, completion: @escaping NWJSONResult<T>) {
        self.dataTaskJSONCore(with: request, T.self) { (result) in
            DispatchQueue.main.async { completion(result) }
        }
    }
    
    public func fetchImage(with url: URL, completion: @escaping NWImageResult) {
        let request = URLRequest(url: url)
        self.fetchImage(with: request) { (result) in
            completion(result)
        }
    }
    
    public func fetchImage(with request: URLRequest, completion: @escaping NWImageResult) {
        self.dataTaskImageCore(with: request) { (result) in
            DispatchQueue.main.async { completion(result) }
        }
    }
}

//MARK: - Private Methods

extension Networker {
    private func dataTaskJSONCore<T: Decodable>(with request: URLRequest, _ type: T.Type, completion: @escaping NWJSONResult<T>) {
        HTTPClient(URLSession.shared).dataTask(with: request) { (result) in
            switch result {
            case .success(let result):
                Networker.log(request, message: result.statusCode)
                do {
                    let result = try T(decoding: result.data, decoder: self.decoder)
                    completion(.success(result))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                Networker.log(request, message: error.localizedDescription)
                completion(.failure(error))
            }
        }
    }
    
    private func dataTaskImageCore(with request: URLRequest, completion: @escaping NWImageResult) {
        HTTPClient(URLSession.shared).dataTask(with: request) { (result) in
            switch result {
            case .success(let result):
                Networker.log(request, message: result.statusCode)
                if let image = UIImage(data: result.data) {
                    completion(.success(image))
                } else {
                    let error = Networker.Error.invalidImageData
                    Networker.log(request, message: error.localizedDescription)
                    completion(.failure(error))
                }
            case .failure(let error):
                Networker.log(request, message: error.localizedDescription)
                completion(.failure(error))
            }
        }
    }
    
    private static func log(_ request: URLRequest, message: String) {
        let url = request.url?.absoluteString ?? "(пустое значение ulr)"
        print("\(module)\n\(url)\n\(message)")
    }
}
