//
//  PersistenceController.swift
//  ShiftClash
//
//  Created by Shashank Nayak on 6/10/2026.
//

import CoreData

final class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ShiftClash")

        if inMemory {
            // Tests use this later. It is a scratch database that disappears when the test ends.
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        } else {
            // This is the real storage location. It is inside the App Group folder,
            // not the private storage used only by the app. This is what lets the
            // widget and the share extension open the same database file.
            let storeURL = AppGroup.containerURL.appendingPathComponent("ShiftClash.sqlite")
            let description = NSPersistentStoreDescription(url: storeURL)
            container.persistentStoreDescriptions = [description]
        }

        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Could not open the Core Data store: \(error.localizedDescription)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

