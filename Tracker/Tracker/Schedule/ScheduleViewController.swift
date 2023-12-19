//
//  ChooseScheduleViewController.swift
//  Tracker
//
//  Created by Dinara on 08.12.2023.
//

import UIKit
import SnapKit

// MARK: - Protocol
protocol ScheduleViewControllerDelegate: AnyObject {
    func didSelectDays(_ days: [WeekDay])
}

final class ScheduleViewController: UIViewController {

    // MARK: - ScheduleViewControllerDelegate
    weak var delegate: ScheduleViewControllerDelegate?

    // MARK: - Private properties
    private var selectedWeekDays: Set<WeekDay> = []

    // MARK: - UI
    private lazy var navBarLabel: UILabel = {
        let label = UILabel()
        label.text = "Расписание"
        label.textColor = UIColor(named: "YP Black")
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()

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

    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16,
                                                    weight: .medium)
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        button.layer.cornerRadius = 16
        button.backgroundColor = UIColor(named: "YP Black")
        return button
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }

    // MARK: - Setup Views
    private func setupViews() {
        view.backgroundColor = UIColor.white

        [navBarLabel,
         tableView,
         doneButton
        ].forEach  {
            view.addSubview($0)
        }
    }

    // MARK: - Setup Constraints
    private func setupConstraints() {
        navBarLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.centerX.equalToSuperview()
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(navBarLabel.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(525)
        }

        doneButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-50)
            make.height.equalTo(60)
        }
    }

    // MARK: - Actions
    @objc private func doneButtonTapped() {
        let weekDays = Array(selectedWeekDays)
        delegate?.didSelectDays(weekDays)
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - ScheduleCellDelegate
extension ScheduleViewController: ScheduleCellDelegate {
    func switchButtonDidTap(to isSelected: Bool, of weekDay: WeekDay) {
        if isSelected {
            selectedWeekDays.insert(weekDay)
        } else {
            selectedWeekDays.remove(weekDay)
        }
    }
    

}

// MARK: - UITableViewDataSource
extension ScheduleViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ScheduleCell.cellID,
            for: indexPath) as? ScheduleCell else {
            fatalError("Could not cast to CreateTrackerCell")
        }

        let weekDay = WeekDay.allCases[indexPath.row]
        if indexPath.row == 6 {
            cell.configureCell(with: weekDay, 
                               isLastCell: true,
                               isSelected: selectedWeekDays.contains(weekDay))
        } else {
            cell.configureCell(with: weekDay, 
                               isLastCell: false,
                               isSelected: selectedWeekDays.contains(weekDay))
        }
        cell.delegate = self
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ScheduleViewController: UITableViewDelegate {
    //TODO
}

// MARK: - Enum WeekDay
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
