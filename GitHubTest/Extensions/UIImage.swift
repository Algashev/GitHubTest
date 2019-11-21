//
//  UIImage.swift
//  GitHubTest
//
//  Created by Александр Алгашев on 21.11.2019.
//  Copyright © 2019 Александр Алгашев. All rights reserved.
//

import UIKit

extension UIImage {
    @discardableResult
    func safeAsPngWith(name: String?) -> Bool {
        guard let name = name else { return false }
        do {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let avatarsURL = documentsURL.appendingPathComponent("avatars", isDirectory: true)
            if !FileManager.default.fileExists(atPath: avatarsURL.path) {
                do {
                    try FileManager.default.createDirectory(at: avatarsURL, withIntermediateDirectories: false, attributes: nil)
                } catch {
                    return false
                }
            }
            let fileURL = avatarsURL.appendingPathComponent("\(name).png")
            if let pngImageData = self.pngData() {
                try pngImageData.write(to: fileURL, options: .atomic)
            }
            return true
        } catch {
            return false
        }
    }
    
    convenience init?(fromPngFileWithName name: String) {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let avatarsURL = documentsURL.appendingPathComponent("avatars", isDirectory: true)
        let filePath = avatarsURL.appendingPathComponent("\(name).png").path
        if FileManager.default.fileExists(atPath: filePath) {
            self.init(contentsOfFile: filePath)
        } else {
            return nil
        }
    }
}
