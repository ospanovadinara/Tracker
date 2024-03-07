//
//  CategoryCell.swift
//  Tracker
//
//  Created by Dinara on 04.03.2024.
//

import UIKit
import SnapKit

final class CategoryCell: UITableViewCell {

    // MARK: - Public properties
    public static let cellID = String(describing: CategoryCell.self)

    // MARK: - UI
    private let title: UILabel = {
        let title = UILabel()
        title.textColor = UIColor(named: "YP Black")
        title.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        return title
    }()

    private let image: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark_icon")
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
    func configureCell(with title: String, isSelected: Bool) {
        self.title.text = title
        image.isHidden = !isSelected
    }

    func getSelectedCategoryTitle() -> String {
        guard let selectedCategoryTitle = self.title.text else { return "" }

        return selectedCategoryTitle
    }

    func setRoundedCornersForContentView(top: Bool) {
        var cornerMask: CACornerMask = []

        if top {
            cornerMask.insert(.layerMinXMinYCorner)
            cornerMask.insert(.layerMaxXMinYCorner)
        }

        contentView.layer.maskedCorners = cornerMask
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true
    }

    func setRoundedCornersForContentView(bottom: Bool) {
        var cornerMask: CACornerMask = []

        if bottom {
            cornerMask.insert(.layerMinXMaxYCorner)
            cornerMask.insert(.layerMaxXMaxYCorner)
        }

        contentView.layer.maskedCorners = cornerMask
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true
    }
}

private extension CategoryCell {
    // MARK: Setup Views
    func setupViews() {
        contentView.backgroundColor = UIColor(named: "YP Gray")?.withAlphaComponent(0.3)

        [title,
         image
        ].forEach {
            contentView.addSubview($0)
        }
    }

    // MARK: Setup Constraints
    func setupConstraints() {
        title.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(27)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(22)
        }
    }
}
