//
//  TrackerHeaderView.swift
//  Tracker
//
//  Created by Dinara on 27.11.2023.
//

import UIKit
import SnapKit

final class TrackerHeaderView: UICollectionReusableView {
    // MARK: - Public properties
    public static let cellID = String(describing: TrackerHeaderView.self)

    // MARK: - UI
    private lazy var title: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 19)
        label.textAlignment = .left
        return label
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
    public func configureCell(with model: [TrackerCategory]) {
        if let firstModel = model.first {
            title.text = firstModel.title
        }
    }
}

private extension TrackerHeaderView {
    func setupViews() {
        self.addSubview(title)
    }

    func setupConstraints() {
        title.snp.makeConstraints { make in
//            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(18)
        }
    }
}
