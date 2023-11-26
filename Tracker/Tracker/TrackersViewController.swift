//
//  MainTrackerViewController.swift
//  Tracker
//
//  Created by Dinara on 23.11.2023.
//

import UIKit
import SnapKit

final class TrackersViewController: UIViewController {
    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []

    // MARK: - UI
    private lazy var navBarTitle: UILabel = {
        let title = UILabel()
        title.text = "Трекеры"
        title.font = UIFont.boldSystemFont(ofSize: 34)
        title.textColor = UIColor.black
        title.sizeToFit()
        return title
    }()

    private lazy var navBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: UIImage(named: "plus_icon"),
            style: .plain,
            target: self,
            action: #selector(navBarButtonTapped)
        )
        return button
    }()

    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        return datePicker
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupViews()
        setupConstraints()
    }

    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = navBarButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        let navigationController = UINavigationController(rootViewController: TrackersViewController())
    }

    private func setupViews() {
        view.addSubview(navBarTitle)
    }

    private func setupConstraints() {
        navBarTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(93)
            make.leading.equalToSuperview().offset(16)
            make.height.equalTo(41)
        }
    }

    // MARK: - Actions
    @objc private func navBarButtonTapped() {

    }
}

