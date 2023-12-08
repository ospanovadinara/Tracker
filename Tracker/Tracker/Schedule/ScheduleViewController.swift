//
//  ChooseScheduleViewController.swift
//  Tracker
//
//  Created by Dinara on 08.12.2023.
//

import UIKit
import SnapKit

final class ScheduleViewController: UIViewController {

    // MARK: - UI
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.register(ScheduleCell.self,
                           forCellReuseIdentifier: ScheduleCell.cellID)
        tableView.backgroundColor = UIColor(named: "YP Gray")?.withAlphaComponent(0.3)
        tableView.layer.cornerRadius = 16
        return tableView
    }()

}

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
}

extension ScheduleViewController: UITableViewDelegate {

}

enum WeekDay: String, CaseIterable {
    case monday = "Понедельник"
    case tuesday = "Вторник"
    case wednesday = "Среда"
    case thursday = "Четверг"
    case friday = "Пятница"
    case saturday = "Суббота"
    case sunday = "Воскресенье"

    var shortTitle: String {
        switch self {

        case .monday:
            return "Пн"
        case .tuesday:
            return "Вт"
        case .wednesday:
            return "Ср"
        case .thursday:
            return "Чт"
        case .friday:
            return "Пт"
        case .saturday:
            return "Сб"
        case .sunday:
            return "Вс"
        }
    }
}
