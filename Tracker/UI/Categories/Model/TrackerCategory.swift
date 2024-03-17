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

    func visibleTrackers(filterString: String, pin: Bool?) -> [Tracker] {
        if filterString.isEmpty {
            return pin == nil ? trackers : trackers.filter { $0.isPinned == pin }
        } else {
            return pin == nil ? trackers
                .filter { $0.title.lowercased().contains(filterString.lowercased()) }
            : trackers
                .filter { $0.title.lowercased().contains(filterString.lowercased()) }
                .filter { $0.isPinned == pin }
        }
    }
}
