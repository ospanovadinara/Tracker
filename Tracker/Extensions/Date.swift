//
//  Date.swift
//  Tracker
//
//  Created by Dinara on 20.03.2024.
//

import Foundation

extension Date {
    var yearMonthDayComponents: DateComponents {
        Calendar.current.dateComponents([.year, .month, .day], from: self)
    }
}
