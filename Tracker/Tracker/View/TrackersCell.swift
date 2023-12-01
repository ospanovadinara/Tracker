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
    public func configureCell(with model: Tracker) {
        emojiLabel.text = model.emoji
        trackerLabel.text = model.title
        trackerContainer.backgroundColor = model.color
    }
}

private extension TrackersCell {
    // MARK: - Setup Views
    func setupViews() {
        contentView.addSubview(trackerContainer)
        trackerContainer.addSubview(stackView)
        [emojiLabel,
        trackerLabel
        ].forEach {
            stackView.addArrangedSubview($0)
        }
    }

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
    }
}
