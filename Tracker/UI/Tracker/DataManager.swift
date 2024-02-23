//
//  DataManager.swift
//  Tracker
//
//  Created by Dinara on 09.01.2024.
//

import UIKit
import CoreData

final class DataManager {
    static let shared = DataManager()
    private let modelName = "TrackerModel"
    var categories: [TrackerCategory] = []

// MARK: - CoreData Stack
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: modelName)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                assertionFailure("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    private init() {
        _ = persistentContainer
    }

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                context.rollback()
                let nserror = error as NSError
                assertionFailure("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
