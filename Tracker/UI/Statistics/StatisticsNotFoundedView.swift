//
//  StatisticsNotFoundedView.swift
//  Tracker
//
//  Created by Dinara on 18.03.2024.
//

import UIKit
import SnapKit

final class StatisticsNotFoundedView: UIView {

    // MARK: - UI
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "statistics_notFounded")
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "YP Black")
        label.text = "Анализировать пока нечего"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()

    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension StatisticsNotFoundedView {
    // MARK: - Setup Views
    private func setupViews() {
        [imageView,
         titleLabel
        ].forEach {
            self.addSubview($0)
        }
    }

    // MARK: - Setup Constraints
    private func setupConstraints() {
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(80)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(8)
            make.centerX.equalTo(imageView.snp.centerX)
        }
    }
}
