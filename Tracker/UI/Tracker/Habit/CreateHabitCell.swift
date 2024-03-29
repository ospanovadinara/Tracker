//
//  CreateHabitCell.swift
//  Tracker
//
//  Created by Dinara on 07.12.2023.
//

import SnapKit
import UIKit

final class CreateHabitCell: UITableViewCell {
    // MARK: - Public properties
    public static let cellID = String(describing: CreateHabitCell.self)

    // MARK: - UI
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "YP Black")
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        return label
    }()

    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "YP Dark Gray")
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()

    private lazy var customSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "YP Dark Gray")
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
         subtitleLabel,
         customSeparatorView
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
            make.top.equalToSuperview().offset(15)
            make.leading.equalToSuperview().inset(16)
            make.height.equalTo(22)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-14)
            make.height.equalTo(22)
        }

        customSeparatorView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(1.0)
            make.bottom.equalToSuperview()
        }
    }

    // MARK: - Public Methods
    func configureCell(with title: String, subtitle: String?, isFirstCell: Bool) {
        titleLabel.text = title
        customSeparatorView.isHidden = !isFirstCell
        if let subtitle {
            subtitleLabel.text = subtitle
        }
    }
}
