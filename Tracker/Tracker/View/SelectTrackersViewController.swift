//
//  TrackersCreationViewController.swift
//  Tracker
//
//  Created by Dinara on 02.12.2023.
//

import UIKit
import SnapKit

final class SelectTrackersViewController: UIViewController {
    
    // MARK: - UI
    private lazy var navBarLabel: UILabel = {
        let label = UILabel()
        label.text = "Создание трекера"
        label.textColor = UIColor(named: "YP Black")
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()

    private lazy var trackerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Привычка", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.backgroundColor = UIColor(named: "YP Black")
        button.addTarget(self, action: #selector(trackerButtonTapped), for: .touchUpInside)
        button.layer.cornerRadius = 16
        return button
    }()

    private lazy var irregularEventButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Нерегулярное событие", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.backgroundColor = UIColor(named: "YP Black")
        button.addTarget(self, action: #selector(irregularEventButtonTapped), for: .touchUpInside)
        button.layer.cornerRadius = 16
        return button
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }

    // MARK: - Setup Views
    private func setupViews() {
        view.backgroundColor = .white
        [navBarLabel,
         trackerButton,
         irregularEventButton
        ].forEach {
            view.addSubview($0)
        }
    }

    // MARK: - Setup Constraints
    private func setupConstraints() {
        navBarLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.centerX.equalToSuperview()
        }

        trackerButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.height.equalTo(60)
        }

        irregularEventButton.snp.makeConstraints { make in
            make.top.equalTo(trackerButton.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(60)
        }
    }

    // MARK: - Actions
    @objc private func trackerButtonTapped() {
        let viewController = CreateTrackersViewController()
        present(viewController, animated: true, completion: nil)
    }

    @objc private func irregularEventButtonTapped() {
        let viewController = IrregularEventCreationViewController()
        present(viewController, animated: true, completion: nil)
    }
}
