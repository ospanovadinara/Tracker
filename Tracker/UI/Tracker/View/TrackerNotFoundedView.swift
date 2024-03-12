//
//  TrackerNotFoundedView.swift
//  Tracker
//
//  Created by Dinara on 10.01.2024.
//

import UIKit
import SnapKit

final class TrackerNotFoundedView: UIView {
    // MARK: - UI
    private lazy var image: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "error_icon")
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor(named: "YP Black")
        label.text = "Ничего не найдено"
        label.textAlignment = .center
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

    // MARK: - Setup Views
    private func setupViews() {
        [image,
         titleLabel
        ].forEach {
            self.addSubview($0)
        }
    }

    // MARK: - Setup Constraints
    private func setupConstraints() {
        image.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(80)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(image.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
    }
}
