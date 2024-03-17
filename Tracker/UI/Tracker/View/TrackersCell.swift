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
    func trackerCompleted(id: UUID)
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
        view.backgroundColor = UIColor(named: "YP White")
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
        label.textColor = UIColor(named: "YP White")
        label.textAlignment = .left
        return label
    }()

    private lazy var color: UIColor = {
        let color = UIColor()
        return color
    }()

    private lazy var roundedButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = UIColor(named: "YP White")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.addTarget(self,
                         action: #selector(roundedButtonDidTap),
                         for: .touchUpInside)
        return button
    }()

    private lazy var trackersDaysCounter: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "YP Black")
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.text = "0 день"
        return label
    }()

    private lazy var pinImageView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "pin_square")
        image.isHidden = false
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
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
        _ id: UUID,
        title: String,
        color: UIColor,
        emoji: String,
        isCompleted: Bool,
        isEnabled: Bool,
        completedDays:Int,
        isPinned: Bool
    ) {
        trackerId = id
        trackerLabel.text = title
        trackerContainer.backgroundColor = color
        roundedButton.backgroundColor = color
        emojiLabel.text = emoji
        pinImageView.isHidden = !isPinned
        isCompletedToday = isCompleted

        let completedDaysText = convertCompletedDays(completedDays)
        trackersDaysCounter.text = completedDaysText

        roundedButton.setImage(isCompletedToday ? UIImage(systemName: "checkmark")! : UIImage(systemName: "plus")!, for: .normal)

        if isCompletedToday == true  {
            roundedButton.layer.opacity = 0.2
        } else {
            roundedButton.layer.opacity = 1
        }
        roundedButton.isEnabled = isEnabled
    }

    private func convertCompletedDays(_ completedDays: Int) -> String {
        let formatString = NSLocalizedString("numberValue", comment: "Completed days of Tracker")
        return String.localizedStringWithFormat(formatString, completedDays)
    }
}

private extension TrackersCell {
    // MARK: - Setup Views
    func setupViews() {

        [trackerContainer,
         roundedButton,
         trackersDaysCounter,
         pinImageView
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

        pinImageView.snp.makeConstraints { make in
            make.height.equalTo(12)
            make.width.equalTo(8)
            make.top.equalTo(trackerContainer.snp.top).offset(18)
            make.trailing.equalTo(trackerContainer.snp.trailing).offset(-12)
        }
    }

    // MARK: - Actions
    @objc func roundedButtonDidTap() {
        guard let trackerId = trackerId else {
            assertionFailure("No trackerId")
            return
        }
        delegate?.trackerCompleted(id: trackerId)
    }
}
