//
//  MainTrackerViewController.swift
//  Tracker
//
//  Created by Dinara on 23.11.2023.
//

import UIKit
import SnapKit

final class MainTrackerViewController: UIViewController {

    // MARK: - UI
    private lazy var navBarTitle: UILabel = {
        let title = UILabel()
        title.text = "Трекеры"
        title.font = UIFont.boldSystemFont(ofSize: 34)
        title.textColor = UIColor.black
        title.sizeToFit()
        return title
    }()

    private lazy var navBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(named: "plus_icon"),
                                     style: .plain,
                                     target: self,
                                     action: #selector(navBarButtonTapped))
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupViews()
        setupConstraints()
    }

    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = navBarButton
        let navigationController = UINavigationController(rootViewController: MainTrackerViewController())
    }

    private func setupViews() {
        view.addSubview(navBarTitle)
    }

    private func setupConstraints() {
        navBarTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(88)
            make.leading.equalToSuperview().offset(16)
            make.height.equalTo(41)
        }
    }

    // MARK: - Actions
    @objc private func navBarButtonTapped() {

    }
}

