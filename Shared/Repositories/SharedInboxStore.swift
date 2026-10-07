//
//  SharedInboxStore.swift
//  ShiftClash
//
//  Created by Shashank Nayak on 7/10/2026.
//

import Foundation

// Stores roster messages from the share extension as a JSON file in the
// App Group folder, separate from Core Data so the app and the share
// extension are not writing to the same database at the same time.
final class SharedInboxStore {
    private let fileURL: URL

    init(fileURL: URL = AppGroup.containerURL.appendingPathComponent("RosterInbox.json")) {
        self.fileURL = fileURL
    }

    func messages() -> [SharedRosterMessage] {
        guard let data = try? Data(contentsOf: fileURL) else { return [] }
        return (try? JSONDecoder().decode([SharedRosterMessage].self, from: data)) ?? []
    }

    func add(_ message: SharedRosterMessage) {
        var all = messages()
        all.append(message)
        save(all)
    }

    func remove(_ message: SharedRosterMessage) {
        var all = messages()
        all.removeAll { $0.id == message.id }
        save(all)
    }

    private func save(_ messages: [SharedRosterMessage]) {
        guard let data = try? JSONEncoder().encode(messages) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
