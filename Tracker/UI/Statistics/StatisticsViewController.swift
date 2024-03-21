//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Dinara on 23.11.2023.
//

import SnapKit
import UIKit

protocol StatisticsViewControllerDelegate: AnyObject {
    func updateStatistics()
}

final class StatisticsViewController: UIViewController {

    private let trackerRecordStore = TrackerRecordStore()
    private var completedTrackers: [TrackerRecord] = []
    weak var delegate: StatisticsViewControllerDelegate?

    // MARK: - UI

    private lazy var navBarLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "YP Black")
        label.text = "Статистика"
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        return label
    }()

    private lazy var container: UIView = {
        let view = UIView()
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "YP Black")
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textAlignment = .left
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "YP Black")
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .left
        return label
    }()

    private lazy var statisticsNotFoundedView: StatisticsNotFoundedView = {
        let view = StatisticsNotFoundedView()
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        trackerRecordStore.delegate = self
        updateTrackerRecords()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        container.addGradienBorder(
            colors: [
                UIColor(named: "YP Red") ?? .red,
                UIColor(named: "YP Green") ?? .green,
                UIColor(named: "YP Light Blue") ?? .blue
            ],
            width: 1
        )
    }
}

private extension StatisticsViewController {
    // MARK: - Setup Views
    func setupViews() {
        view.backgroundColor = UIColor.systemBackground

        [titleLabel,
         subtitleLabel
        ].forEach {
            container.addSubview($0)
        }

        [navBarLabel,
         container,
         statisticsNotFoundedView
        ].forEach {
            view.addSubview($0)
        }
    }

    // MARK: - Setup Constraints
    func setupConstraints() {
        navBarLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(88)
            make.leading.equalToSuperview().offset(16)
        }

        container.snp.makeConstraints { make in
            make.top.equalTo(navBarLabel.snp.bottom).offset(77)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(90)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(container.snp.top).offset(12)
            make.leading.equalTo(container.snp.leading).offset(12)
            make.trailing.equalTo(container.snp.trailing).offset(-12)
            make.height.equalTo(41)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(container.snp.bottom).offset(-12)
            make.leading.equalTo(container.snp.leading).offset(12)
            make.trailing.equalTo(container.snp.trailing).offset(-12)
            make.height.equalTo(18)
        }

        statisticsNotFoundedView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func updateTrackerRecords() {
        completedTrackers = trackerRecordStore.trackerRecords
        titleLabel.text = "\(completedTrackers.count)"
        subtitleLabel.text = String.localizedStringWithFormat(NSLocalizedString("trackersCompleted", comment: "число дней"), completedTrackers.count)
        statisticsNotFoundedView.isHidden = completedTrackers.count > 0
        container.isHidden = completedTrackers.count == 0
        delegate?.updateStatistics()
        trackerRecordStore.reload()
        updateStatistics()
    }
}

// MARK: - TrackerRecordStoreDelegate
extension StatisticsViewController: TrackerRecordStoreDelegate {
    func store(_ store: TrackerRecordStore, didUpdate update: TrackerRecordStoreUpdate) {
        DispatchQueue.main.async{
            self.updateTrackerRecords()
        }
    }
}

// MARK: - StatisticsViewControllerDelegate
extension StatisticsViewController: StatisticsViewControllerDelegate {
    func updateStatistics() {
        DispatchQueue.main.async{
            self.updateTrackerRecords()
        }
    }
}
