//
//  RosterInboxViewModel.swift
//  ShiftClash
//
//  Created by Shashank Nayak on 7/10/2026.
//

import Foundation
import Combine

@MainActor
final class RosterInboxViewModel: ObservableObject {
    @Published var messages: [SharedRosterMessage] = []

    private let inboxStore: SharedInboxStore

    init(inboxStore: SharedInboxStore) {
        self.inboxStore = inboxStore
    }

    func load() {
        messages = inboxStore.messages().sorted { $0.receivedAt > $1.receivedAt }
    }

    func dismiss(_ message: SharedRosterMessage) {
        inboxStore.remove(message)
        load()
    }
}
