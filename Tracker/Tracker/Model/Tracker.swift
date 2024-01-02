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
    let scedule: [WeekDay]
    var completedDays: [Date]
}

struct NewTracker {
    var label: String 
    var emoji: String?
    var color: UIColor?
    var schedule: [WeekDay]?
}
