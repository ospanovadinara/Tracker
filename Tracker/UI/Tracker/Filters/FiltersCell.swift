//
//  FiltersCell.swift
//  Tracker
//
//  Created by Dinara on 11.03.2024.
//

import UIKit
import SnapKit

final class FiltersCell: UITableViewCell {

    // MARK: - Public properties
    public static let cellID = String(describing: FiltersCell.self)

    // MARK: - UI
    private lazy var titleLabel: UILabel = {
        let title = UILabel()
        title.textColor = UIColor(named: "YP Black")
        title.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        return title
    }()

    private lazy var image: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        imageView.image = UIImage(named: "checkmark_icon")
        return imageView
    }()

    // MARK: - Lifecycle
    override init(
        style: UITableViewCell.CellStyle,
        reuseIdentifier: String?
    ) {
        super.init(
            style: style,
            reuseIdentifier: reuseIdentifier
        )

        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods
    func configureCell(
        with title: String,
        isHidden: Bool
    ) {
        self.titleLabel.text = title
        self.image.isHidden = isHidden
    }

    func checkMarkImageSetup(isHidden: Bool) {
        self.image.isHidden = isHidden
    }

    func setRoundedCornersForContentView(top: Bool, bottom: Bool) {
        var cornerMask: CACornerMask = []

        if top {
            cornerMask.insert(.layerMinXMinYCorner)
            cornerMask.insert(.layerMaxXMinYCorner)
        }

        if bottom {
            cornerMask.insert(.layerMinXMaxYCorner)
            cornerMask.insert(.layerMaxXMaxYCorner)
        }

        contentView.layer.maskedCorners = cornerMask
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true
    }
}

private extension FiltersCell {
    // MARK: Setup Views
    func setupViews() {
        self.backgroundColor = UIColor(named: "YP Gray")?.withAlphaComponent(0.3)

        [titleLabel,
         image
        ].forEach {
            contentView.addSubview($0)
        }
    }

    // MARK: Setup Constraints
    func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
        }

        image.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.size.equalTo(14)
        }
    }
}
