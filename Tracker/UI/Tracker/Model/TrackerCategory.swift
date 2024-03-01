//
//  TrackerCategory.swift
//  Tracker
//
//  Created by Dinara on 25.11.2023.
//

import Foundation

struct TrackerCategory {
    let title: String
    let trackers: [Tracker]

    func visibleTrackers(filterString: String) -> [Tracker] {
        if filterString.isEmpty {
            return trackers
        } else {
            return trackers.filter {
                $0.title.lowercased().contains(filterString.lowercased()) }
        }
    }
}
