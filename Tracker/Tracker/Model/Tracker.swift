//
//  Tracker.swift
//  Tracker
//
//  Created by Dinara on 25.11.2023.
//

import UIKit

struct Tracker {
    let id: UUID
    let title: String
    let color: UIColor
    let emoji: String
    let scedule: Date?
    var completedDays: [Date]

    var daysCount: Int {
           return completedDays.count
       }
}
