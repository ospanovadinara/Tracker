//
//  CategoriesViewModel.swift
//  Tracker
//
//  Created by Dinara on 05.03.2024.
//

import Foundation

protocol CategoriesViewModelDelegate: AnyObject {
    func didSelectCategory(category: TrackerCategory)
}

final class CategoriesViewModel: NSObject {
    var updateClosure: (() -> Void)?

    private(set) var categories = [TrackerCategory]() {
        didSet {
            updateClosure?()
        }
    }
    private(set) var selectedCategory: TrackerCategory?
    private let trackerCategoryStore = TrackerCategoryStore.shared
    private weak var delegate: CategoriesViewModelDelegate?

    // MARK: - Lifecycle
    init(
        selectedCategory: TrackerCategory?,
        delegate: CategoriesViewModelDelegate?
    ) {
        self.selectedCategory = selectedCategory
        self.delegate = delegate

        super.init()

        trackerCategoryStore.delegate = self
        categories = trackerCategoryStore.trackerCategories
    }

    func selectCategory(with title: String) {
        let category = TrackerCategory(title: title, trackers: [])
        delegate?.didSelectCategory(category: category)
    }

    func selectedCategory(_ category: TrackerCategory) {
        selectedCategory = category
        delegate?.didSelectCategory(category: category)
        updateClosure?()
    }
}

extension CategoriesViewModel: TrackerCategoryStoreDelegate {
    func store(_ store: TrackerCategoryStore, didUpdate update: TrackerCategoryStoreUpdate) {
        print("Categories updated")
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.categories = trackerCategoryStore.trackerCategories
        }
    }
}
