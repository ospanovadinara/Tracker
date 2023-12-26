//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Dinara on 23.11.2023.
//

import UIKit
import SnapKit

final class TrackersViewController: UIViewController {

    // MARK: - Private protperties
    private var trackers: [Tracker] = []
    private var categories: [TrackerCategory] = []
    private lazy var category: TrackerCategory = {
        return TrackerCategory(title: "Домашние дела", trackers: self.trackers)
    }() //тестовая категория
    private var visibleCategories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    var currentDate: Date = Date()

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
        datePicker.maximumDate = Date()
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

        if !trackers.isEmpty {
            emptyView.isHidden = true
        }
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
         searchBar,
         emptyView
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

        emptyView.snp.makeConstraints { make in
//            make.top.leading.trailing.bottom.equalToSuperview()
            make.center.equalToSuperview()
        }
    }
}

// MARK: - Actions
extension TrackersViewController {
    @objc private func addNavBarButtonTapped() {
        let viewController = ChooseTrackerViewController()
        viewController.trackersViewController = self
        present(viewController, animated: true, completion: nil)
    }

    @objc private func datePickerValueChanged() {
        currentDate = datePicker.date
        collectionView.reloadData()
    }
}

// MARK: - UISearchBarDelegate
extension TrackersViewController: UISearchBarDelegate {

}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return trackers.count // поменять на categories
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if trackers.isEmpty {
            collectionView.backgroundView = emptyView
            emptyView.isHidden = false
        } else {
            collectionView.backgroundView = nil
            emptyView.isHidden = true
        }

        return trackers.count
    }

    func collectionView(_ collectionView: UICollectionView, 
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackersCell.cellID,
            for: indexPath
        ) as? TrackersCell else {
            fatalError("Could not cast to TrackersCell")
        }

        let cellData = trackers // поменять на categories
        let tracker = cellData[indexPath.row]
//        let tracker = cellData[indexPath.section].trackers[indexPath.row]



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

// MARK: - TrackersCellDelgate
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

extension TrackersViewController: CreateHabitViewControllerDelegate {
    func reloadData() {
        collectionView.reloadData()
    }
    
    //TODO 
    func createButtonidTap(tracker: Tracker, category: String) {
        self.trackers.append(tracker)
        self.categories = self.categories.map { category in
            var updatedTrackers = category.trackers
            updatedTrackers.append(tracker)
            return TrackerCategory(title: category.title, trackers: updatedTrackers)
        }
        collectionView.reloadData()
        dismiss(animated: true)
    }

    func cancelButtonDidTap() {
        dismiss(animated: true)
    }
}

