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
    private var visibleCategories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []

    var currentDate: Date = Date()

    // Оставила как пример реализации ячейки
    private var trackersModel: [Tracker] = [
        Tracker(id: UUID(),
                title: "Помыть посуду",
                color: UIColor.blue,
                emoji: "❤️",
                scedule: nil, 
                completedDays: [])
    ]

    init() {
        super.init(nibName: nil, bundle: nil)
        self.categories = [TrackerCategory(title: "Домашний уют",
                                           trackers: self.trackersModel)]
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI
    private lazy var navBarTitle: UILabel = {
        let title = UILabel()
        title.text = "Трекеры"
        title.font = UIFont.boldSystemFont(ofSize: 34)
        title.textColor = UIColor.black
        title.sizeToFit()
        return title
    }()

    private lazy var addNavBarButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "plus_icon"), for: .normal)
        button.addTarget(self, action: #selector(addNavBarButtonTapped), for: .touchUpInside)
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

    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = "Поиск"
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        return searchBar
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
        collectionView.register(TrackerHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: TrackerHeaderView.cellID)

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
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: addNavBarButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }

    // MARK: - Setup Views
    private func setupViews() {
        [collectionView,
         navBarTitle,
         searchBar
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

        searchBar.snp.makeConstraints { make in
            make.top.equalTo(navBarTitle.snp.bottom)
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(24)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

// MARK: - Actions
extension TrackersViewController {
    @objc private func addNavBarButtonTapped() {
        let viewController = SelectTrackersViewController()
        present(viewController, animated: true, completion: nil)
    }

    @objc private func datePickerValueChanged() {
        currentDate = datePicker.date
        collectionView.reloadData()
    }
}

extension TrackersViewController: UISearchBarDelegate {

}

// MARK: - CreateTrackerDelegate
extension TrackersViewController: CreateTrackerDelegate {
    func didCreateTracker(_ tracker: Tracker) {
        categories = categories.map({ category in
            var updatedTrackers = category.trackers
            updatedTrackers.append(tracker)
            return TrackerCategory(title: category.title, trackers: updatedTrackers)
        })
        trackersModel.append(tracker)
        reloadData()
    }

    func reloadData() {
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if trackersModel.isEmpty {
            collectionView.backgroundView = emptyView
        } else {
            collectionView.backgroundView = nil
        }

        return trackersModel.count
    }

    func collectionView(_ collectionView: UICollectionView, 
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackersCell.cellID,
            for: indexPath
        ) as? TrackersCell else {
            fatalError("Could not cast to TrackersCell")
        }

        let cellData = categories
        let tracker = cellData[indexPath.section].trackers[indexPath.row]

        cell.delegate = self
        let isCompletedToday = isTrackerCompletedToday(id: tracker.id)
        let completedDays = completedTrackers.filter {
            $0.trackerID == tracker.id
        }.count


        cell.configureCell(
            with: tracker,
            isCompletedToday: isCompletedToday, 
            completedDays: completedDays,
            indexPath: indexPath
        )
        return cell
    }

    private func isTrackerCompletedToday(id: UUID) -> Bool {
        completedTrackers.contains { trackerRecord in
            isSameTrackerRecord(trackerRecord: trackerRecord, id: id)
        }
    }

    private func isSameTrackerRecord(trackerRecord: TrackerRecord, id: UUID) -> Bool {
        let isSameDay = Calendar.current.isDate(trackerRecord.date,
                                                inSameDayAs: datePicker.date)
        return trackerRecord.trackerID == id && isSameDay
    }
}

extension TrackersViewController: TrackersCellDelgate {
    func completeTracker(id: UUID, at indexPath: IndexPath) {
        let trackerRecord = TrackerRecord(date: datePicker.date, trackerID: id)
        completedTrackers.append(trackerRecord)

        collectionView.reloadItems(at: [indexPath])
    }
    
    func uncompleteTracker(id: UUID, at indexPath: IndexPath) {
        completedTrackers.removeAll { trackerRecord in
            isSameTrackerRecord(trackerRecord: trackerRecord, id: id)
        }

        collectionView.reloadItems(at: [indexPath])
    }
}

// MARK: - UICollectionViewDelegate
extension TrackersViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard let sectionHeaderView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: TrackerHeaderView.cellID,
            for: indexPath) as? TrackerHeaderView else {
            fatalError("Could not cast to TrackerHeaderView")
        }

        sectionHeaderView.configureCell(with: categories)
        return sectionHeaderView
    }

    func collectionView(_ collectionView: UICollectionView, 
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 30) 
    }

    func collectionView(_ collectionView: UICollectionView, 
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 167, height: 148)
    }

    func collectionView(_ collectionView: UICollectionView, 
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0,
                            left: 16,
                            bottom: 0,
                            right: 0)
    }
}

