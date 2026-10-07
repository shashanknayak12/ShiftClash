//
//  RosterInboxView.swift
//  ShiftClash
//
//  Created by Shashank Nayak on 7/10/2026.
//

import SwiftUI

struct RosterInboxView: View {
    @StateObject private var viewModel: RosterInboxViewModel
    @State private var messageToTurnIntoShift: SharedRosterMessage?

    private let repository: ScheduleRepository

    init(repository: ScheduleRepository, inboxStore: SharedInboxStore) {
        self.repository = repository
        _viewModel = StateObject(wrappedValue: RosterInboxViewModel(inboxStore: inboxStore))
    }

    var body: some View {
        NavigationStack {
            List {
                if viewModel.messages.isEmpty {
                    ContentUnavailableView(
                        "Your roster inbox is empty.",
                        systemImage: "tray",
                        description: Text("Share a roster message or link from another app to see it here.")
                    )
                } else {
                    ForEach(viewModel.messages) { message in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(message.text)
                            Text(message.receivedAt, format: .dateTime.day().month().hour().minute())
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            HStack {
                                Button("Turn into Shift") {
                                    messageToTurnIntoShift = message
                                }
                                .buttonStyle(.borderedProminent)
                                Button("Dismiss", role: .destructive) {
                                    viewModel.dismiss(message)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Roster Inbox")
            .onAppear(perform: viewModel.load)
            .sheet(item: $messageToTurnIntoShift) { message in
                AddShiftView(repository: repository, initialNote: message.text) {
                    viewModel.dismiss(message)
                }
            }
        }
    }
}
