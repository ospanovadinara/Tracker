//
//  TrackersCell.swift
//  Tracker
//
//  Created by Dinara on 26.11.2023.
//

import UIKit
import SnapKit

// MARK: - TrackersCellDelegate
protocol TrackersCellDelgate: AnyObject {
    func trackerCompleted(id: UUID, at indexPath: IndexPath)
}

final class TrackersCell: UICollectionViewCell {

    weak var delegate: TrackersCellDelgate?

    // MARK: - Public properties
    public static let cellID = String(describing: TrackersCell.self)

    // MARK: - Private properties
    private var trackersModel: [Tracker] = []
    private var isCompletedToday: Bool = false
    private var indexPath: IndexPath?
    private var trackerId: UUID?

    // MARK: - UI
    private lazy var trackerContainer: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 16
        return view
    }()

    private lazy var emojiBackground: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        view.layer.cornerRadius = view.frame.width / 2
        view.layer.opacity = 0.6
        return view
    }()

    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .center
        return label
    }()

    private lazy var trackerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor.white
        label.textAlignment = .left
        return label
    }()

    private lazy var color: UIColor = {
        let color = UIColor()
        return color
    }()

    private lazy var roundedButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.addTarget(self,
                         action: #selector(roundedButtonDidTap),
                         for: .touchUpInside)
        button.setTitle("+", for: .normal)
        return button
    }()

    private lazy var trackersDaysCounter: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.text = "0 день"
        return label
    }()

    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Method
    public func configureCell(
        with tracker: Tracker,
        isCompleted: Bool,
        isEnabled: Bool,
        completedDays:Int,
        indexPath: IndexPath
    ) {
        self.trackerId = tracker.id
        self.isCompletedToday = isCompleted
        self.indexPath = indexPath

        emojiLabel.text = tracker.emoji
        trackerLabel.text = tracker.title
        trackerContainer.backgroundColor = tracker.color
        roundedButton.backgroundColor = tracker.color

        let wordDays = convertCompletedDays(completedDays)
        trackersDaysCounter.text = wordDays

        let roundedButtonTitle = isCompleted ? "✓" : "+"

        roundedButton.setTitle(roundedButtonTitle, for: .normal)

        if isCompletedToday == true  {
            roundedButton.layer.opacity = 0.2
        } else {
            roundedButton.layer.opacity = 1
        }
        roundedButton.isEnabled = isEnabled
    }

    private func convertCompletedDays(_ completedDays: Int) -> String {
        let lasyNumber = completedDays % 10
        let lastTwoNumbers = completedDays % 100
        if lastTwoNumbers >= 11 && lastTwoNumbers <= 19 {
            return "\(completedDays) дней"
        }

        switch lasyNumber {
        case 1:
            return "\(completedDays) день"
        case 2, 3, 4:
            return "\(completedDays) дня"
        default:
            return "\(completedDays) дней"
        }
    }
}

private extension TrackersCell {
    // MARK: - Setup Views
    func setupViews() {

        [trackerContainer,
         roundedButton,
         trackersDaysCounter
        ].forEach {
            contentView.addSubview($0)
        }

        [emojiBackground,
         emojiLabel,
         trackerLabel
        ].forEach {
            trackerContainer.addSubview($0)
        }
    }

    // MARK: - Setup Constraints
    func setupConstraints() {
        emojiBackground.snp.makeConstraints { make in
            make.top.equalTo(trackerContainer.snp.top).offset(12)
            make.leading.equalTo(trackerContainer.snp.leading).offset(12)
            make.height.equalTo(24)
            make.width.equalTo(24)
        }

        emojiLabel.snp.makeConstraints { make in
            make.centerX.equalTo(emojiBackground.snp.centerX)
            make.centerY.equalTo(emojiBackground.snp.centerY)
            make.height.equalTo(18)
            make.width.equalTo(18)
        }

        trackerLabel.snp.makeConstraints { make in
            make.leading.equalTo(trackerContainer.snp.leading).offset(12)
            make.bottom.equalTo(trackerContainer.snp.bottom).offset(-12)
        }

        trackerContainer.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.width.equalTo(167)
            make.height.equalTo(90)
        }

        trackersDaysCounter.snp.makeConstraints { make in
            make.top.equalTo(trackerContainer.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(12)
            make.width.equalTo(101)
            make.height.equalTo(18)
        }

        roundedButton.snp.makeConstraints { make in
            make.centerY.equalTo(trackersDaysCounter.snp.centerY)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(34)
            make.width.equalTo(34)
        }
    }

    // MARK: - Actions
    @objc func roundedButtonDidTap() {
        guard let trackerId = trackerId, let indexPath = indexPath else {
            assertionFailure("No trackerId")
            return
        }
        delegate?.trackerCompleted(id: trackerId, at: indexPath)
    }
}
