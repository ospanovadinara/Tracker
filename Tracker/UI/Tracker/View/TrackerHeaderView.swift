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
    private lazy var  containerView: UIView = {
        let view = UIView()
        return view
    }()

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
    public func configureCell(with model: TrackerCategory) {
        title.text = model.title
    }
}

private extension TrackerHeaderView {
    func setupViews() {
        self.addSubview(containerView)
        containerView.addSubview(title)
    }

    func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(32)
        }

        title.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(28)
            make.trailing.equalToSuperview()
            make.height.equalTo(20)
        }
    }
}
