//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Dinara on 23.11.2023.
//

import UIKit
import SnapKit

final class TrackersViewController: UIViewController {
    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    var currentDate: Date = Date()
    private var trackersModel: [Tracker] = []
//  var completedTrackers: Set<UUID> = []



    // MARK: - UI
    private lazy var navBarTitle: UILabel = {
        let title = UILabel()
        title.text = "Трекеры"
        title.font = UIFont.boldSystemFont(ofSize: 34)
        title.textColor = UIColor.black
        title.sizeToFit()
        return title
    }()

    private lazy var navBarButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "plus_icon"), for: .normal)
        button.addTarget(self, action: #selector(navBarButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self,
                             action: #selector(datePickerValueChanged),
                             for: .valueChanged)
        return datePicker
    }()

    private lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        return layout
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackersCell.self,
                                forCellWithReuseIdentifier: TrackersCell.cellID)

        return collectionView
    }()

    private lazy var emptyView: TrackersEmptyView = {
        let view = TrackersEmptyView()
        return view
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupViews()
        setupConstraints()
    }

    // MARK: - Setup NavigationBar
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navBarButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        let navigationController = UINavigationController(rootViewController: TrackersViewController())
    }

    // MARK: - Setup Views
    private func setupViews() {
        [collectionView,
         navBarTitle
        ].forEach {
            view.addSubview($0)
        }
    }

    // MARK: - Setup Constraints
    private func setupConstraints() {
        navBarTitle.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(16)
            make.height.equalTo(41)
        }

        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: - Actions
extension TrackersViewController {
    @objc private func navBarButtonTapped() {

    }

    @objc private func datePickerValueChanged() {

    }
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if trackersModel.isEmpty {
            collectionView.backgroundView = emptyView
        } else {
            collectionView.backgroundView = nil
        }

        return trackersModel.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackersCell.cellID,
            for: indexPath
        ) as? TrackersCell else {
            fatalError("Could not cast to TrackersCell")
        }

        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension TrackersViewController: UICollectionViewDelegate {

}
