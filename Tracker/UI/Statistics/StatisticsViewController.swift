//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Dinara on 23.11.2023.
//

import UIKit
import SnapKit

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
    private func setupViews() {
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
    private func setupConstraints() {
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

    private func updateTrackerRecords() {
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

extension StatisticsViewController: TrackerRecordStoreDelegate {
    func store(_ store: TrackerRecordStore, didUpdate update: TrackerRecordStoreUpdate) {
        DispatchQueue.main.async{
            self.updateTrackerRecords()
        }
    }
}

extension StatisticsViewController: StatisticsViewControllerDelegate {
    func updateStatistics() {
        DispatchQueue.main.async{
            self.updateTrackerRecords()
        }
    }
}


extension UIView {
    private static let kLayerNameGradientBorder = "GradientBorderLayer"

    func addGradienBorder(
        colors: [UIColor],
        width: CGFloat,
        startPoint: CGPoint = CGPoint(x: 0, y: 0.5),
        endPoint: CGPoint = CGPoint(x: 1, y: 0.5)
    ) {
        let existingBorder = gradientBorderLayer()
        let border = existingBorder ?? CAGradientLayer()
        border.frame = bounds
        border.colors = colors.map { $0.cgColor }
        border.startPoint = startPoint
        border.endPoint = endPoint

        let mask = CAShapeLayer()
        mask.path = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: 16
        ).cgPath
        mask.fillColor = UIColor.clear.cgColor
        mask.strokeColor = UIColor.white.cgColor
        mask.lineWidth = width

        border.mask = mask

        let isAlreadyAdded = existingBorder != nil
        if !isAlreadyAdded {
            layer.addSublayer(border)
        }
    }

    private func gradientBorderLayer() -> CAGradientLayer? {
        let borderLayers = layer.sublayers?.filter {
            $0.name == UIView.kLayerNameGradientBorder
        }
        if borderLayers?.count ?? 0 > 1 {
            fatalError()
        }
        return borderLayers?.first as? CAGradientLayer
    }

    func removeGradientBorder() {
        self.gradientBorderLayer()?.removeFromSuperlayer()
    }
}
