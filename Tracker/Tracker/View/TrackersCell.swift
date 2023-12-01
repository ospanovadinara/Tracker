//
//  TrackersCell.swift
//  Tracker
//
//  Created by Dinara on 26.11.2023.
//

import UIKit
import SnapKit

final class TrackersCell: UICollectionViewCell {
    // MARK: - Public properties
    public static let cellID = String(describing: TrackersCell.self)

    // MARK: - Private properties
    private var trackersModel: [Tracker] = []

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
        label.font = UIFont.systemFont(ofSize: 12)
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
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.layer.cornerRadius = 16
        button.addTarget(self,
                         action: #selector(roundedPlusButtonDidTap),
                         for: .touchUpInside)
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
    public func configureCell(with model: Tracker, trackersModel: [Tracker]) {
        emojiLabel.text = model.emoji
        trackerLabel.text = model.title
        trackerContainer.backgroundColor = model.color
        roundedPlusButton.backgroundColor = model.color

        self.trackersModel = trackersModel
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
        print("Rounded Button Did Tap")
        guard let collectionView = self.superview as? UICollectionView,
              let indexPath = collectionView.indexPath(for: self) else {
            return
        }
        var tracker = trackersModel[indexPath.item]
        let currentDate = Date()

        if tracker.completedDays.contains(currentDate) {
            if let index = tracker.completedDays.firstIndex(of: currentDate) {
                tracker.completedDays.remove(at: index)
                roundedPlusButton.setImage(UIImage(systemName: "plus"), for: .normal)
            }
        } else {
            tracker.completedDays.append(currentDate)
            roundedPlusButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
        }
        
        self.trackersModel[indexPath.item] = tracker
        updateDaysCounterLabel()
    }

    func updateDaysCounterLabel() {
        guard let collectionView = self.superview as? UICollectionView,
              let indexPath = collectionView.indexPath(for: self) else {
            return
        }

        let tracker = trackersModel[indexPath.item]
        trackersDaysCounter.text = "\(tracker.daysCount) дней"
    }
}
