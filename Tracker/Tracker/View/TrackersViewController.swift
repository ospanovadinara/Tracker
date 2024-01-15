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
    private var visibleCategories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    var currentDate: Date = Date()
    private var createHabitViewControllerDelegate: CreateHabitViewControllerDelegate?
    private var dataManager = DataManager.shared

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
                             action: #selector(datePickerValueChanged),
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

        reload()
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

    private func reload() {
        categories = dataManager.categories
        visibleCategories = categories
        datePickerValueChanged()
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
        reloadVisibleCategories()
    }

    private func reloadVisibleCategories() {
        let calendar = Calendar.current
        let filterWeekday = calendar.component(.weekday, from: datePicker.date)
        let filterText = (searchTextField.text ?? "").lowercased()

        visibleCategories = categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                let textCondition = filterText.isEmpty ||
                tracker.title.lowercased().contains(filterText)

                let dateCondition = tracker.scedule.contains { weekDay in
                    weekDay.numberValue == filterWeekday
                } == true

                return textCondition && dateCondition
            }

            if trackers.isEmpty {
                return nil
            }

            return TrackerCategory(
                title: category.title,
                trackers: trackers
            )
        }
        collectionView.reloadData()
        reloadPlaceHolder()
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
        if visibleCategories.isEmpty {

            let newCategory = TrackerCategory(title: category, trackers: [tracker])
            visibleCategories.append(newCategory)
        } else {
            if let existingCategoryIndex = visibleCategories.firstIndex(where: { $0.title == category }) {
                var updatedTrackers = visibleCategories[existingCategoryIndex].trackers
                updatedTrackers.append(tracker)
                visibleCategories[existingCategoryIndex] = TrackerCategory(title: category, trackers: updatedTrackers)
            } else {
                let newCategory = TrackerCategory(title: category, trackers: [tracker])
                visibleCategories.append(newCategory)
            }
        }
        self.trackers.append(tracker)
        collectionView.reloadData()
        dismiss(animated: true)
    }

    func cancelButtonDidTap() {
        dismiss(animated: true)
    }
}

