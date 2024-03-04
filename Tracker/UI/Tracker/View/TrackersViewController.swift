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
    private var currentDate: Int?
    private var createHabitViewControllerDelegate: CreateHabitViewControllerDelegate?
    private var dataManager = DataManager.shared
    private var searchText: String = ""

    private var categories = [TrackerCategory]()
    private var visibleCategories = [TrackerCategory]()
    private var completedTrackers = [TrackerRecord]()

    private let trackerCategoryStore = TrackerCategoryStore.shared
    private let trackerRecordStore = TrackerRecordStore.shared

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
        datePicker.locale = Locale(identifier: "ru_Ru")
        datePicker.addTarget(self,
                             action: #selector(datePickerValueChanged(sender:)),
                             for: .valueChanged)
        return datePicker
    }()

    private lazy var searchTextField: UISearchTextField = {
        let textField = UISearchTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Поиск"
        textField.delegate = self
        return textField
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

    private lazy var trackerNotFoundedView: TrackerNotFoundedView = {
        let view = TrackerNotFoundedView()
        return view
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setWeekDay()
        reloadVisibleCategories()
        setupNavigationBar()
        setupViews()
        setupConstraints()

        do {
            completedTrackers = try trackerRecordStore.fetchTrackerRecords()
        } catch {
            print("Error with fetchTrackers: \(error.localizedDescription)")
        }

        trackerCategoryStore.delegate = self
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
         searchTextField,
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

        searchTextField.snp.makeConstraints { make in
            make.top.equalTo(navBarTitle.snp.bottom)
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
            make.height.equalTo(36)
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(searchTextField.snp.bottom).offset(24)
            make.leading.trailing.bottom.equalToSuperview()
        }

        emptyView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    // MARK: - Actions
    @objc private func addNavBarButtonTapped() {
        let viewController = ChooseTrackerViewController()
        viewController.trackersViewController = self
        present(viewController, animated: true, completion: nil)
    }

    @objc private func datePickerValueChanged(sender: UIDatePicker) {
        let components = Calendar.current.dateComponents([.weekday], from: sender.date)
        if let day = components.weekday {
            currentDate = day
            reloadVisibleCategories()
        }
    }

    private func setWeekDay() {
        let components = Calendar.current.dateComponents([.weekday], from: Date())
        currentDate = components.weekday
    }

    private func reloadVisibleCategories() {
        var newCategories = [TrackerCategory]()
        visibleCategories = trackerCategoryStore.trackerCategories

        for category in visibleCategories {
            var newTrackers = [Tracker]()
            for tracker in category.visibleTrackers(filterString: searchText) {
                guard let schedule = tracker.schedule else { return }
                let scheduleIntegers = schedule.map { $0.numberValue }
                if let day = currentDate, scheduleIntegers.contains(day) && (
                    searchText.isEmpty ||
                    tracker.title.lowercased().contains(searchText.lowercased())
                ) {
                    newTrackers.append(tracker)
                }
            }

            if newTrackers.count > 0 {
                let newCategory = TrackerCategory(
                    title: category.title,
                    trackers: newTrackers
                )
                newCategories.append(newCategory)
            }
        }
        visibleCategories = newCategories
        collectionView.reloadData()
    }

    private func reloadPlaceHolder()  {
        if !categories.isEmpty && visibleCategories.isEmpty {
            collectionView.backgroundView = trackerNotFoundedView
            emptyView.isHidden = true
        }
    }
}

// MARK: - UISearchBarDelegate
extension TrackersViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchText = searchTextField.text ?? ""
        reloadPlaceHolder()
        visibleCategories = trackerCategoryStore.predicateFetch(trackerTitle: searchText)
        reloadVisibleCategories()
        return true
    }
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if visibleCategories.isEmpty {
            collectionView.backgroundView = emptyView
            emptyView.isHidden = false
        } else {
            collectionView.backgroundView = nil
            emptyView.isHidden = true
        }
        return visibleCategories[section].trackers.count
    }

    func collectionView(_ collectionView: UICollectionView, 
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackersCell.cellID,
            for: indexPath
        ) as? TrackersCell else {
            fatalError("Could not cast to TrackersCell")
        }

        let cellData = visibleCategories
        let tracker = cellData[indexPath.section].trackers[indexPath.row]


        cell.delegate = self
        let isCompletedToday = completedTrackers.contains(where: { trackerRecord in
            trackerRecord.trackerID == tracker.id &&
            trackerRecord.date.yearMonthDayComponents == datePicker.date.yearMonthDayComponents
        })
        let completedDays = completedTrackers.filter {
            $0.trackerID == tracker.id
        }.count
        let isEnabled = datePicker.date <= Date() || Date().yearMonthDayComponents == datePicker.date.yearMonthDayComponents

        cell.configureCell(
            with: tracker,
            isCompleted: isCompletedToday,
            isEnabled: isEnabled,
            completedDays: completedDays,
            indexPath: indexPath
        )
        return cell
    }
}

// MARK: - TrackersCellDelgate
extension TrackersViewController: TrackersCellDelgate {
    func trackerCompleted(id: UUID, at indexPath: IndexPath) {
        if let index = completedTrackers.firstIndex(where: { trackerRecord in
            trackerRecord.trackerID == id &&
            trackerRecord.date.yearMonthDayComponents == datePicker.date.yearMonthDayComponents
        }) {
            completedTrackers.remove(at: index)
            try? trackerRecordStore.deleteTrackerRecord(TrackerRecord(date: datePicker.date, trackerID: id))
        } else {
            completedTrackers.append(TrackerRecord(date: datePicker.date, trackerID: id))
            try? trackerRecordStore.addNewTracker(TrackerRecord(date: datePicker.date, trackerID: id))
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

        let categoryForSection = visibleCategories[indexPath.section]
        sectionHeaderView.configureCell(with: categoryForSection)
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
        
        let leftInset = CGFloat(16)
        let rightInset = CGFloat(16)
        let itemsPerRow = CGFloat(2)
        let cellSpacing = CGFloat(10)
        let padding = leftInset + rightInset + CGFloat(itemsPerRow - 1) * cellSpacing
        let availableWidth = collectionView.frame.width - padding
        let cellWidth = availableWidth / itemsPerRow

        return CGSize(width: cellWidth, height: 148)
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
    
    func createButtonidTap(tracker: Tracker, category: String) {
        var updatedCategory: TrackerCategory?
        let categories: [TrackerCategory] = trackerCategoryStore.trackerCategories

        for item in 0..<categories.count {
            if categories[item].title == category {
                updatedCategory = categories[item]
            }
        }

        if updatedCategory != nil {
            try? trackerCategoryStore.addTrackerToCategory(tracker, to: updatedCategory ?? TrackerCategory(
                title: category,
                trackers: [tracker]
            ))
        } else {
            let trackerCategory = TrackerCategory(
                title: category,
                trackers: [tracker]
            )
            updatedCategory = trackerCategory
            try? trackerCategoryStore.addNewTrackerCategory(updatedCategory ?? TrackerCategory(
                title: category,
                trackers: [tracker]
            ))
        }

        reloadVisibleCategories()
    }

    func cancelButtonDidTap() {
        dismiss(animated: true)
    }
}

extension TrackersViewController: TrackerCategoryStoreDelegate {
    func store(_ store: TrackerCategoryStore, didUpdate update: TrackerCategoryStoreUpdate) {
        visibleCategories = trackerCategoryStore.trackerCategories
        collectionView.reloadData()
    }
}
