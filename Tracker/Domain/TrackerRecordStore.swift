//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Dinara on 23.02.2024.
//

import Foundation
import CoreData

final class TrackerRecordStore {
    static let shared = TrackerRecordStore()
    private let context: NSManagedObjectContext

    convenience init() {
        let context = DataManager.shared.context
        self.init(context: context)
    }

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func addNewTracker(_ trackerRecord: TrackerRecord) throws {
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)

        trackerRecordCoreData.id = trackerRecord.trackerID
        trackerRecordCoreData.date = trackerRecord.date

        try context.save()
    }

    func deleteTrackerRecord(_ trackerRecord: TrackerRecord) throws {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        request.predicate = NSPredicate(format: "id == %@ AND date == %@", trackerRecord.trackerID as CVarArg, trackerRecord.date as CVarArg)

        if let existingRecord = try context.fetch(request).first {
            context.delete(existingRecord)
            try context.save()
        }
    }

    func trackerRecord(from trackerRecordCoreData: TrackerRecordCoreData) throws -> TrackerRecord {
        guard
            let id = trackerRecordCoreData.id,
            let date = trackerRecordCoreData.date
        else { throw DataError.dataError }

        return TrackerRecord(
            date: date,
            trackerID: id
        )
    }

    func fetchTrackerRecords() throws -> [TrackerRecord] {
        let request = TrackerRecordCoreData.fetchRequest()
        let trackerRecordFromCoreData = try context.fetch(request)

        return try trackerRecordFromCoreData.map { try self.trackerRecord(from: $0) }
    }
}
