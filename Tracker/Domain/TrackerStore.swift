//
//  TrackerStore.swift
//  Tracker
//
//  Created by Dinara on 23.02.2024.
//

import Foundation
import CoreData

struct TrackerStoreUpdate {
    struct Move: Hashable {
        let oldIndex: Int
        let newIndex: Int
    }
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
    let movedIndexes: Set<Move>
}

protocol TrackerStoreDelegate: AnyObject {
    func store(
        _ store: TrackerStore,
        didUpdate update: TrackerStoreUpdate
    )
}

final class TrackerStore: NSObject {
    static let shared = TrackerStore()
    weak var delegate: TrackerStoreDelegate?
    private let context: NSManagedObjectContext
    private let uiColorMarshalling = UIColorMarshalling()
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>!
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<TrackerStoreUpdate.Move>?

    convenience override init() {
        let context = DataManager.shared.context
        self.init(context: context)
        do {
            try fetchedResultsController.performFetch()
        } catch {
            assertionFailure("TrackerStore fetch failed")
        }
    }

    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()

        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCoreData.title, ascending: true)
        ]
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        self.fetchedResultsController = controller
    }

    var trackers: [Tracker] {
        guard let objects = self.fetchedResultsController.fetchedObjects, let trackers = try? objects.map({ try self.tracker(from: $0)})
        else { return [] }
        return trackers
    }

    func addNewTracker(_ tracker: Tracker) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        updateExistingTracker(trackerCoreData, with: tracker)
        try context.save()
    }

    func changeTrackerPinStatus(_ tracker: Tracker) throws {
        let trackerIndex = fetchedResultsController.fetchedObjects?.firstIndex { $0.id == tracker.id }

        if let index = trackerIndex {
            fetchedResultsController.fetchedObjects?[index].isPinned = !(fetchedResultsController.fetchedObjects?[index].isPinned ?? false)
            try context.save()

        }
    }

    func updateExistingTracker(_ trackerCoreData: TrackerCoreData, with tracker: Tracker) {
        let trackerColor = uiColorMarshalling.hexString(from: tracker.color)

        trackerCoreData.id = tracker.id
        trackerCoreData.title = tracker.title
        trackerCoreData.color = trackerColor
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.schedule = tracker.schedule?.compactMap { $0.rawValue }
    }

    func updateTracker(
        newTitle: String,
        newEmoji: String,
        newColor: String,
        newSchedule: [WeekDay],
        categoryTitle: String,
        editableTracker: Tracker) throws {
            let tracker = fetchedResultsController.fetchedObjects?.first {
                $0.id == editableTracker.id
            }
            tracker?.title = newTitle
            tracker?.emoji = newEmoji
            tracker?.color = newColor
            tracker?.schedule = newSchedule.compactMap { $0.rawValue }
            if (tracker?.category?.title != categoryTitle) {
                tracker?.category = TrackerCategoryStore().category(categoryTitle)
            }
            try context.save()
        }

    func deleteTracker(_ trackerToDelete: Tracker) throws {
        let tracker = fetchedResultsController.fetchedObjects?.first {
            $0.id == trackerToDelete.id
        }
        if let tracker = tracker {
            context.delete(tracker)
            try context.save()
        }
    }

    func tracker(from tracker: TrackerCoreData) throws -> Tracker {
        let trackerColor = uiColorMarshalling.color(from: tracker.color ?? "")

        guard
            let id = tracker.id,
            let title = tracker.title,
            let color = trackerColor,
            let emoji = tracker.emoji,
            let schedule = tracker.schedule
        else {
            throw DataError.dataError
        }

        let pinned = tracker.isPinned

        return Tracker(
            id: id,
            title: title,
            color: color,
            emoji: emoji,
            schedule: schedule.compactMap { WeekDay(rawValue: $0) }, 
            isPinned: pinned
        )
    }

    func fetchTrackers() throws -> [Tracker] {
        let request = TrackerCoreData.fetchRequest()
        let trackersFromCoreData = try context.fetch(request)

        return try trackersFromCoreData.map { try self.tracker(from: $0) }
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            insertedIndexes = IndexSet()
            deletedIndexes = IndexSet()
            updatedIndexes = IndexSet()
            movedIndexes = Set<TrackerStoreUpdate.Move>()
        }

    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            delegate?.store(
                self,
                didUpdate: TrackerStoreUpdate(
                    insertedIndexes: insertedIndexes ?? [],
                    deletedIndexes: deletedIndexes ?? [],
                    updatedIndexes: updatedIndexes ?? [],
                    movedIndexes: movedIndexes ?? []
                )
            )
            insertedIndexes = nil
            deletedIndexes = nil
            updatedIndexes = nil
            movedIndexes = nil
        }

    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
            case .insert:
                guard let indexPath = newIndexPath else {
                    assertionFailure("insert indexPath - nil")
                    return
                }
                insertedIndexes?.insert(indexPath.item)
            case .delete:
                guard let indexPath = indexPath else {
                    assertionFailure("delete indexPath - nil")
                    return
                }
                deletedIndexes?.insert(indexPath.item)
            case .update:
                guard let indexPath = indexPath else {
                    assertionFailure("update indexPath - nil")
                    return
                }
                updatedIndexes?.insert(indexPath.item)
            case .move:
                guard let oldIndexPath = indexPath, let newIndexPath = newIndexPath else {
                    assertionFailure("move indexPath - nil")
                    return
                }
                movedIndexes?.insert(.init(oldIndex: oldIndexPath.item, newIndex: newIndexPath.item))
            @unknown default:
                assertionFailure("unknown case")
        }
    }
}
