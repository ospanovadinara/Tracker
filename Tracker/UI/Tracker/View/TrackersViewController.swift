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
    private var selectedFilter: Filters?
    private let trackerStore = TrackerStore.shared
    private var pinnedTrackers: [Tracker] = []
    weak var statisticsViewControllerDelegate: StatisticsViewControllerDelegate?
    private let analyticsService = AnalyticsService()

    // MARK: - Localized Strings
    private let navBarTitleText = NSLocalizedString("navBarTitleText", comment: "Text displayed on the main screen title")
    private let filterButtonTitleText = NSLocalizedString("filterButtonTitleText", comment: "Text displayed on the filter button")


    // MARK: - UI
    private lazy var navBarTitle: UILabel = {
        let title = UILabel()
        title.text = navBarTitleText
        title.font = UIFont.boldSystemFont(ofSize: 34)
        title.textColor = UIColor(named: "YP Black")
        title.sizeToFit()
        return title
    }()

    private lazy var addNavBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNavBarButtonTapped))
        button.tintColor = UIColor(named: "YP Black")
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
        collectionView.alwaysBounceVertical = true

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

    private lazy var filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(filterButtonTitleText, for: .normal)
        button.setTitleColor(UIColor(named: "YP White"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17,
                                                    weight: .regular)
        button.addTarget(self, action: #selector(filterButtonTapped(sender:)), for: .touchUpInside)
        button.layer.cornerRadius = 16
        button.backgroundColor = UIColor(named: "YP Blue")
        return button
    }()

    

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setWeekDay()
        reloadVisibleCategories(with: trackerCategoryStore.trackerCategories)
        setupNavigationBar()
        setupViews()
        setupConstraints()
        completedTrackers = trackerRecordStore.trackerRecords
        trackerCategoryStore.delegate = self
        trackerRecordStore.delegate = self
        trackerStore.delegate = self

        analyticsService.report(event: .open, params: ["Screen" : "Main"])
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        analyticsService.report(event: .close, params: ["Screen" : "Main"])
    }

    // MARK: - Setup NavigationBar
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = addNavBarButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }

    // MARK: - Setup Views
    private func setupViews() {
        [collectionView,
         navBarTitle,
         searchTextField,
         emptyView,
         filterButton
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
            make.top.equalTo(searchTextField.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
            make.centerX.equalToSuperview()

        }

        filterButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalTo(114)
        }
    }

    // MARK: - Actions
    @objc private func addNavBarButtonTapped() {
        let statisticsViewController = StatisticsViewController()
        statisticsViewController.delegate = self
        let viewController = ChooseTrackerViewController()
        viewController.trackersViewController = self
        present(viewController, animated: true, completion: nil)
        analyticsService.report(event: .click, params: ["Screen" : "Main", "Item" : Items.add_track.rawValue])
    }

    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        let components = Calendar.current.dateComponents([.weekday], from: sender.date)
        if let day = components.weekday {
            currentDate = day
            reloadVisibleCategories(with: trackerCategoryStore.trackerCategories)
        }
    }

    @objc func filterButtonTapped(sender: AnyObject) {
        analyticsService.report(event: .click, params: ["Screen" : "Main", "Item" : Items.filter.rawValue])
        let filtersViewController = FiltersViewController()
        filtersViewController.selectedFilter = selectedFilter
        filtersViewController.delegate = self
        present(filtersViewController, animated: true)
    }

    private func setWeekDay() {
        let components = Calendar.current.dateComponents([.weekday], from: Date())
        currentDate = components.weekday
    }

    private func reloadVisibleCategories(with categories: [TrackerCategory]) {
        var newCategories = [TrackerCategory]()
        var pinnedTrackers: [Tracker] = []

        for category in categories {
            var newTrackers = [Tracker]()
            for tracker in category.visibleTrackers(filterString: searchText, pin: nil) {
                guard let schedule = tracker.schedule else { continue }
                let scheduleIntegers = schedule.map { $0.numberValue }
                if let day = currentDate, scheduleIntegers.contains(day) {

                    if selectedFilter == .completed {
                        updateNotFoundedFilter(filter: .completed)
                        if !completedTrackers.contains(where: { record in
                            record.trackerID == tracker.id &&
                            record.date.yearMonthDayComponents == datePicker.date.yearMonthDayComponents
                        }) {
                            continue
                        }
                    }
                    if selectedFilter == .incompleted {
                        updateNotFoundedFilter(filter: .incompleted)
                        if completedTrackers.contains(where: { record in
                            record.trackerID == tracker.id &&
                            record.date.yearMonthDayComponents == datePicker.date.yearMonthDayComponents
                        }) {
                            continue
                        }
                        newTrackers.append(tracker)
                    } 
                    if tracker.isPinned == true {
                        pinnedTrackers.append(tracker)
                    } else {
                        newTrackers.append(tracker)
                    }
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
        self.pinnedTrackers = pinnedTrackers
        collectionView.reloadData()
        updateEmptyView()
    }

    private func reloadPlaceHolder()  {
        if !categories.isEmpty && visibleCategories.isEmpty {
            collectionView.backgroundView = trackerNotFoundedView
            emptyView.isHidden = true
        }
    }

    private func updateNotFoundedFilter(filter: Filters) {
        var isNotFounded = false
        if selectedFilter == filter {
            isNotFounded = true
        }

        if isNotFounded {
            collectionView.backgroundView = trackerNotFoundedView
        }
    }

    private func updateEmptyView() {
        if visibleCategories.isEmpty {
            print("visibleCategories is empty")
            collectionView.backgroundView = emptyView
            emptyView.isHidden = false
        } else {
            collectionView.backgroundView = nil
            emptyView.isHidden = true
        }
        collectionView.reloadData()
    }

    func setupContextMenu(_ indexPath: IndexPath) -> UIMenu {
        let tracker: Tracker

        if indexPath.section == 0 {
            tracker = pinnedTrackers[indexPath.row]
        } else {
            tracker = visibleCategories[indexPath.section - 1].visibleTrackers(filterString: searchText, pin: false)[indexPath.row]
        }

        let pinActionTitle = tracker.isPinned == true ? "Открепить" : "Закрепить"
        let pinAction = UIAction(title: pinActionTitle, image: nil) { [weak self] action in
            guard let self = self else { return }
            do {
                try self.trackerStore.changeTrackerPinStatus(tracker)
                self.reloadVisibleCategories(with: trackerCategoryStore.trackerCategories)
                self.collectionView.reloadData()
            } catch {
                print("Error pinning tracker: \(error)")
            }
        }

        let editAction = UIAction(title: "Редактировать") { [weak self] action in
            self?.analyticsService.report(event: .click, params: ["Screen" : "Main", "Item" : Items.edit.rawValue])
            let editTrackerViewController = CreateHabitViewController()
            editTrackerViewController.editTracker = tracker
            editTrackerViewController.editTrackerDate = self?.datePicker.date ?? Date()
            editTrackerViewController.category = tracker.category
            self?.present(editTrackerViewController, animated: true)
        }

        let deleteAction = UIAction(title: "Удалить", image: nil, attributes: .destructive) { [weak self] action in
            self?.showAlert(tracker: tracker)
            self?.analyticsService.report(event: .click, params: ["Screen" : "Main", "Item" : Items.delete.rawValue])
        }
        return UIMenu(children: [pinAction, editAction, deleteAction])
    }

    func showAlert(tracker: Tracker) {
        let alert = UIAlertController(
            title: nil,
            message: "Уверены, что хотите удалить трекер?",
            preferredStyle: .actionSheet
        )
        
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            self?.deleteTracker(tracker)
        }
        alert.addAction(deleteAction)

        let cancelAction = UIAlertAction(
            title: "Отменить",
            style: .cancel) { _ in

            }

        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }

    func deleteTracker(_ tracker: Tracker) {
        try? self.trackerStore.deleteTracker(tracker)
        trackerRecordStore.reload()
        updateStatistics()
        do {
            try trackerStore.deleteTracker(tracker)
        } catch {
            print("Ошибка при удалении трекера: \(error)")
        }

        do {
            try trackerRecordStore.deleteAllTrackerRecords(with: tracker.id)
        } catch {
            print("Ошибка при удалении записей: \(error)")
        }
        updateStatistics()
    }
}

// MARK: - UISearchBarDelegate
extension TrackersViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchText = searchTextField.text ?? ""
        reloadPlaceHolder()
        visibleCategories = trackerCategoryStore.predicateFetch(trackerTitle: searchText)
        reloadVisibleCategories(with: trackerCategoryStore.trackerCategories)
        return true
    }
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let count = visibleCategories.count
        collectionView.isHidden = count == 0 && pinnedTrackers.count == 0
        filterButton.isHidden = collectionView.isHidden && selectedFilter == nil
        return count + 1
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return pinnedTrackers.count
        } else {
            return visibleCategories[section - 1].visibleTrackers(filterString: searchText, pin: false).count
        }
    }

    func collectionView(_ collectionView: UICollectionView, 
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackersCell.cellID,
            for: indexPath
        ) as? TrackersCell else {
            fatalError("Could not cast to TrackersCell")
        }

        let tracker: Tracker

        if indexPath.section == 0 {
            tracker = pinnedTrackers[indexPath.row]
        } else {
            tracker = visibleCategories[indexPath.section - 1].visibleTrackers(filterString: searchText, pin: false)[indexPath.row]
        }

        cell.delegate = self
        let isCompletedToday = completedTrackers.contains(where: { trackerRecord in
            trackerRecord.trackerID == tracker.id &&
            trackerRecord.date.yearMonthDayComponents == datePicker.date.yearMonthDayComponents
        })
        let isEnabled = datePicker.date < Date() || Date().yearMonthDayComponents == datePicker.date.yearMonthDayComponents
        let completedDays = completedTrackers.filter {
            $0.trackerID == tracker.id
        }.count
        cell.configureCell(
            tracker.id,
            title: tracker.title,
            color: tracker.color,
            emoji: tracker.emoji,
            isCompleted: isCompletedToday,
            isEnabled: isEnabled,
            completedDays: completedDays,
            isPinned: tracker.isPinned ?? false
        )
        return cell
    }
}

// MARK: - TrackersCellDelgate
extension TrackersViewController: TrackersCellDelgate {
    func trackerCompleted(id: UUID) {
        if let index = completedTrackers.firstIndex(where: { trackerRecord in
            trackerRecord.trackerID == id &&
            trackerRecord.date.yearMonthDayComponents == datePicker.date.yearMonthDayComponents
        }) {
            completedTrackers.remove(at: index)
            try? trackerRecordStore.deleteTrackerRecord(with: id, date: datePicker.date)
        } else {
            completedTrackers.append(TrackerRecord(date: datePicker.date, trackerID: id))
            try? trackerRecordStore.addNewTracker(TrackerRecord(date: datePicker.date, trackerID: id))
            analyticsService.report(event: .click, params: ["Screen" : "Main", "Item" : Items.track.rawValue])
        }
        reloadVisibleCategories(with: trackerCategoryStore.trackerCategories)
        statisticsViewControllerDelegate?.updateStatistics()
        trackerRecordStore.reload()
    }
}

// MARK: - UICollectionViewDelegate
extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard let sectionHeaderView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: TrackerHeaderView.cellID,
            for: indexPath) as? TrackerHeaderView else {
            fatalError("Could not cast to TrackerHeaderView")
        }

        if indexPath.section == 0 {
            sectionHeaderView.title.text = "Закрепленные"
        } else {
            sectionHeaderView.title.text = visibleCategories[indexPath.section - 1].title
        }

        return sectionHeaderView
    }

    func collectionView(_ collectionView: UICollectionView, 
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 && pinnedTrackers.count == 0 {
            return .zero
        }

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

        reloadVisibleCategories(with: trackerCategoryStore.trackerCategories)
    }

    func cancelButtonDidTap() {
        dismiss(animated: true)
    }
}

extension TrackersViewController: TrackerStoreDelegate {
    func store(_ store: TrackerStore, didUpdate update: TrackerStoreUpdate) {
        reloadVisibleCategories(with: trackerCategoryStore.trackerCategories)
        collectionView.reloadData()
    }
}

extension TrackersViewController: TrackerCategoryStoreDelegate {
    func store(_ store: TrackerCategoryStore, didUpdate update: TrackerCategoryStoreUpdate) {
        reloadVisibleCategories(with: trackerCategoryStore.trackerCategories)
        collectionView.reloadData()
    }
}

extension TrackersViewController: TrackerRecordStoreDelegate {
    func store(_ store: TrackerRecordStore, didUpdate update: TrackerRecordStoreUpdate) {
        completedTrackers = trackerRecordStore.trackerRecords
        collectionView.reloadData()
    }
}

extension TrackersViewController: StatisticsViewControllerDelegate {
    func updateStatistics() {
        return
    }
}

extension TrackersViewController: FiltersViewControllerDelegate {
    func filterSelected(filter: Filters) {
        selectedFilter = filter
        searchText = ""

        switch filter {
        case .all:
            reloadVisibleCategories(with: trackerCategoryStore.trackerCategories)
        case .completed:
            reloadVisibleCategories(with: trackerCategoryStore.trackerCategories)
        case .incompleted:
            reloadVisibleCategories(with: trackerCategoryStore.trackerCategories)
        case .today:
            datePicker.date = Date()
            datePickerValueChanged(datePicker)
            reloadVisibleCategories(with: trackerCategoryStore.trackerCategories)
        }
    }
}

extension TrackersViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        let identifier = "\(indexPath.row):\(indexPath.section)" as NSString

        return UIContextMenuConfiguration(identifier: identifier, previewProvider: nil) { _ in
            return self.setupContextMenu(indexPath)
        }
    }
}

