//
//  TrackerRecord.swift
//  Tracker
//
//  Created by Dinara on 25.11.2023.
//

import Foundation

struct TrackerRecord {
    var date: Date
    let trackerID: UUID
}

extension Date {
    var yearMonthDayComponents: DateComponents {
        Calendar.current.dateComponents([.year, .month, .day], from: self)
    }
}
