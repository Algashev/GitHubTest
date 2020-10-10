//
//  Data.swift
//  Networker
//
//  Created by Александр Алгашев on 09.09.2020.
//  Copyright © 2020 Александр Алгашев. All rights reserved.
//

import Foundation

extension Data {
    var utf8String: String { String(decoding: self, as: UTF8.self) }
}
