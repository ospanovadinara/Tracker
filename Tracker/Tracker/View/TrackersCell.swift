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
    func completeTracker(id: UUID, at indexPath: IndexPath)
    func uncompleteTracker(id: UUID, at indexPath: IndexPath)
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

    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        return label
    }()

    private lazy var trackerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor.white
        label.textAlignment = .left
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()

    private lazy var color: UIColor = {
        let color = UIColor()
        return color
    }()

    private lazy var roundedPlusButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.addTarget(self,
                         action: #selector(roundedPlusButtonDidTap),
                         for: .touchUpInside)
        return button
    }()

    private lazy var doneImage: UIImage = {
        let image = UIImage(named: "done_icon") ?? UIImage()
        return image

    }()

    private lazy var plusImage: UIImage = {
        let pointSize = UIImage.SymbolConfiguration(pointSize: 11)
        let image = UIImage(
            systemName: "plus",
            withConfiguration: pointSize
        ) ?? UIImage()
        return image
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
        isCompletedToday: Bool,
        completedDays:Int,
        indexPath: IndexPath
    ) {
        self.trackerId = tracker.id
        self.isCompletedToday = isCompletedToday
        self.indexPath = indexPath

        emojiLabel.text = tracker.emoji
        trackerLabel.text = tracker.title
        trackerContainer.backgroundColor = tracker.color
        roundedPlusButton.backgroundColor = tracker.color

        let wordDays = convertCompletedDays(completedDays)
        trackersDaysCounter.text = wordDays

        let image = isCompletedToday ? doneImage : plusImage
        
        roundedPlusButton.setImage(image, for: .normal)

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
         roundedPlusButton,
         trackersDaysCounter
        ].forEach {
            contentView.addSubview($0)
        }

        trackerContainer.addSubview(stackView)
        [emojiLabel,
         trackerLabel
        ].forEach {
            stackView.addArrangedSubview($0)
        }
    }

    // MARK: - Setup Constraints
    func setupConstraints() {
        trackerContainer.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.width.equalTo(167)
            make.height.equalTo(90)
        }

        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-12)
        }

        trackersDaysCounter.snp.makeConstraints { make in
            make.top.equalTo(trackerContainer.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(12)
            make.width.equalTo(101)
            make.height.equalTo(18)
        }

        roundedPlusButton.snp.makeConstraints { make in
            make.centerY.equalTo(trackersDaysCounter.snp.centerY)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(34)
            make.width.equalTo(34)
        }
    }

    // MARK: - Actions
    @objc func roundedPlusButtonDidTap() {
        guard let trackerId = trackerId, let indexPath = indexPath else {
            assertionFailure("No trackerId")
            return
        }

        if isCompletedToday {
            delegate?.uncompleteTracker(id: trackerId, at: indexPath)
        } else {
            delegate?.completeTracker(id: trackerId, at: indexPath)
        }
    }
}
