//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Dinara on 04.03.2024.
//

import UIKit
import SnapKit

final class OnboardingViewController: UIViewController {

    // MARK: - UI
    private lazy var backgroundView: UIImageView = {
        let view = UIImageView()
        return view
    }()

    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textColor = .black
        return label
    }()

    // MARK: - Private properties
    private let text: String
    private let backgroundImage: UIImage

    // MARK: - Lifecycle
    init(title: String, backgroundImage: UIImage) {
        self.text = title
        self.backgroundImage = backgroundImage
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupConstraints()
    }
}

private extension OnboardingViewController {
    // MARK: - Setup Views
    func setupViews() {
        backgroundView.image = backgroundImage
        label.text = text

        [backgroundView,
         label
        ].forEach {
            view.addSubview($0)
        }
    }

    // MARK: - Setup Constraints
    func setupConstraints() {
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        label.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(388)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(76)
        }
    }

}
