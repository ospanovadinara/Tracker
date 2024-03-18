//
//  EmojiHeader.swift
//  Tracker
//
//  Created by Dinara on 18.01.2024.
//

import UIKit
import SnapKit

final class EmojiHeader: UICollectionReusableView {
    
    // MARK: - Public properties
    public static let cellID = String(describing: EmojiHeader.self)

    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label.textColor = UIColor(named: "YP Black")
        label.text = "Emoji"
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

    private func setupViews() {
        addSubview(label)
    }

    private func setupConstraints() {
        label.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
            make.height.equalTo(18)
        }
    }
}
