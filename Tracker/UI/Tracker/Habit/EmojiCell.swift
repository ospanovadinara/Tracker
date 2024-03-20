//
//  EmojiCell.swift
//  Tracker
//
//  Created by Dinara on 18.01.2024.
//

import SnapKit
import UIKit

final class EmojiCell: UICollectionViewCell {
    // MARK: - Public properties
    public static let cellID = String(describing: EmojiCell.self)

    // MARK: - UI
    lazy var label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32)
        label.text = "😻"
        label.textAlignment = .center
        return label
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
        contentView.addSubview(label)
    }

    // MARK: - Setuo Constraints
    private func setupConstraints() {
        label.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
}
