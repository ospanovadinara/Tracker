//
//  ColorCell.swift
//  Tracker
//
//  Created by Dinara on 19.01.2024.
//

import UIKit
import SnapKit

final class ColorCell: UICollectionViewCell {
    // MARK: - Public properties
    public static let cellID = String(describing: ColorCell.self)

    // MARK: - UI
    lazy var colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup Views
    private func setupViews() {
        contentView.addSubview(colorView)
    }

    // MARK: - Setuo Constraints
    private func setupConstraints() {
        colorView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(40)
        }
    }
}
