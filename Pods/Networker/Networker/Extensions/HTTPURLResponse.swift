//
//  HTTPURLResponse.swift
//  Networker
//
//  Created by Александр Алгашев on 25.05.2020.
//  Copyright © 2020 Александр Алгашев. All rights reserved.
//

import Foundation

extension HTTPURLResponse {
    var localizedStatusCode: String {
        let statusCode = self.statusCode
        let localizedString = HTTPURLResponse.localizedString(forStatusCode: statusCode)
        return "\(statusCode) - \(localizedString)"
    }
}
