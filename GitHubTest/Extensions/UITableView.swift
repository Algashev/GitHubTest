//
//  UITableView.swift
//  GitHubTest
//
//  Created by Александр Алгашев on 20.11.2019.
//  Copyright © 2019 Александр Алгашев. All rights reserved.
//

import UIKit

extension UITableView {
    var maxOffset: CGPoint {
        let y = self.contentSize.height - self.frame.size.height
        return CGPoint(x: 0, y: y)
    }
    var isGreaterOrEqualThanMaxOffset: Bool {
        return self.contentOffset.y >= self.maxOffset.y
    }
    func applyChanges(deletions: [Int], insertions: [Int], updates: [Int]) {
        beginUpdates()
        deleteRows(at: deletions.map(IndexPath.fromRow), with: .automatic)
        insertRows(at: insertions.map(IndexPath.fromRow), with: .automatic)
        reloadRows(at: updates.map(IndexPath.fromRow), with: .automatic)
        endUpdates()
    }
}
