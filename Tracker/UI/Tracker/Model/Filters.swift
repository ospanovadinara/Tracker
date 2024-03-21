//
//  Filters.swift
//  Tracker
//
//  Created by Dinara on 11.03.2024.
//

import Foundation

enum Filters: String, CaseIterable {
    case all = "Все трекеры"
    case completed = "Завершенные"
    case incompleted = "Не завершенные"
    case today = "Трекеры на сегодня"
}
