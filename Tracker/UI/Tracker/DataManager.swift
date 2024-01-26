//
//  DataManager.swift
//  Tracker
//
//  Created by Dinara on 09.01.2024.
//

import UIKit

class DataManager {
    static let shared = DataManager()

    var categories: [TrackerCategory] = [
        TrackerCategory(
            title: "Уборка",
            trackers: [
                Tracker(
                    id: UUID(),
                    title: "Помыть посуду",
                    color: .blue,
                    emoji: "🍽",
                    scedule: [WeekDay.saturday, WeekDay.friday],
                    completedDays: [])
            ]
        ),
        TrackerCategory(
            title: "Сделать уроки",
            trackers: [
                Tracker(
                    id: UUID(),
                    title: "География",
                    color: .green,
                    emoji: "😪",
                    scedule: WeekDay.allCases,
                    completedDays: []
                )
            ]
        )
    ]

    private init() {}
}
