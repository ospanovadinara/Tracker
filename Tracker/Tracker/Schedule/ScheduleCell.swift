//
//  ScheduleCell.swift
//  Tracker
//
//  Created by Dinara on 08.12.2023.
//

import UIKit
import SnapKit
protocol ScheduleCellDelegate: AnyObject {
    func switchButtonDidTap(to isSelected: Bool, of weekDay: WeekDay)
}

final class ScheduleCell: UITableViewCell {
    // MARK: - Public properties
    public static let cellID = String(describing: ScheduleCell.self)

    // MARK: - ScheduleCellDelegate
    weak var delegate: ScheduleCellDelegate?

    // MARK: - Private properties
    private var weekDay: WeekDay?

    // MARK: - UI
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        return label
    }()

    private lazy var customSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "YP Dark Gray")
        return view
    }()

    private lazy var switchButton: UISwitch = {
        let view = UISwitch()
        view.onTintColor = UIColor(named: "YP Blue")
        view.addTarget(self, action: #selector(switchButtonTapped(_:)), for: .valueChanged)
        return view
    }()

    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Setup Views
    private func setupViews() {
        contentView.backgroundColor = UIColor(named: "YP Gray")?.withAlphaComponent(0.3)

        [titleLabel,
         customSeparatorView,
         switchButton
        ].forEach {
            contentView.addSubview($0)
        }
    }

    // MARK: Setup Constraints
    private func setupConstraints() {
        contentView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(75)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(27)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(22)
        }

        customSeparatorView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(1.0)
            make.bottom.equalToSuperview()
        }

        switchButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(titleLabel.snp.centerY)
        }
    }

    // MARK: - Actions
    @objc private func switchButtonTapped(_ sender: UISwitch) {
        guard let weekDay = weekDay else { return }
        delegate?.switchButtonDidTap(to: sender.isOn, of: weekDay)
    }

    // MARK: - Public Methods
    public func configureCell(with weekDay: WeekDay, isLastCell: Bool, isSelected: Bool) {
        self.weekDay = weekDay
        titleLabel.text = weekDay.rawValue
        customSeparatorView.isHidden = isLastCell
        switchButton.isOn = isSelected
    }
}
