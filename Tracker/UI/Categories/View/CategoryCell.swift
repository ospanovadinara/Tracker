//
//  CategoryCell.swift
//  Tracker
//
//  Created by Dinara on 04.03.2024.
//

import SnapKit
import UIKit

final class CategoryCell: UITableViewCell {

    // MARK: - Public properties
    public static let cellID = String(describing: CategoryCell.self)

    // MARK: - UI
    private let titleLabel: UILabel = {
        let title = UILabel()
        title.textColor = UIColor(named: "YP Black")
        title.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        return title
    }()

    private let image: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
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
    func configureCell(with title: String) {
        self.titleLabel.text = title
    }

    func getSelectedCategoryTitle() -> String {
        guard let selectedCategoryTitle = self.titleLabel.text else { return "" }

        return selectedCategoryTitle
    }
    
    func checkMarkIconSetup(with image: UIImage) {
        self.image.image = image
    }
}

private extension CategoryCell {
    // MARK: Setup Views
    func setupViews() {
        contentView.backgroundColor = UIColor(named: "YP Gray")?.withAlphaComponent(0.3)

        [titleLabel,
         image
        ].forEach {
            contentView.addSubview($0)
        }
    }

    // MARK: Setup Constraints
    func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(27)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.size.equalTo(24)
        }

        image.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.height.equalTo(14)
        }
    }
}
