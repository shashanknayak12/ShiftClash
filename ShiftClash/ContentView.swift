//
//  ContentView.swift
//  ShiftClash
//
//  Created by Shashank Nayak on 4/10/2026.
//

import SwiftUI

struct ContentView: View {
    private let repository: ScheduleRepository = CoreDataScheduleRepository()
    private let inboxStore = SharedInboxStore()

    var body: some View {
        TabView {
            ThisWeekView(repository: repository)
                .tabItem { Label("This Week", systemImage: "calendar") }

            SubjectsView(repository: repository)
                .tabItem { Label("Subjects", systemImage: "book") }

            RosterInboxView(repository: repository, inboxStore: inboxStore)
                .tabItem { Label("Roster Inbox", systemImage: "tray") }
        }
    }
}

#Preview {
    ContentView()
}
