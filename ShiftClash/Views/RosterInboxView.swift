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
                        VStack(alignment: .leading, spacing: 8) {
                            Label {
                                Text(message.text)
                            } icon: {
                                Image(systemName: "text.bubble.fill")
                                    .foregroundStyle(.white)
                                    .frame(width: 28, height: 28)
                                    .background(Color.purple)
                                    .clipShape(Circle())
                                    .shadow(color: .purple.opacity(0.35), radius: 3, y: 2)
                            }
                            Text(message.receivedAt, format: .dateTime.day().month().hour().minute())
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            HStack {
                                Button {
                                    messageToTurnIntoShift = message
                                } label: {
                                    Label("Turn into Shift", systemImage: "briefcase.fill")
                                }
                                .buttonStyle(.borderedProminent)
                                Button(role: .destructive) {
                                    viewModel.dismiss(message)
                                } label: {
                                    Label("Dismiss", systemImage: "xmark")
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Roster Inbox")
            .onAppear(perform: viewModel.load)
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                viewModel.load()
            }
            .sheet(item: $messageToTurnIntoShift) { message in
                AddShiftView(repository: repository, initialNote: message.text) {
                    viewModel.dismiss(message)
                }
            }
        }
    }
}
