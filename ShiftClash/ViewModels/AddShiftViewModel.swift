//
//  AddShiftViewModel.swift
//  ShiftClash
//
//  Created by Shashank Nayak on 7/10/2026.
//

import Foundation
import Combine
import WidgetKit

@MainActor
final class AddShiftViewModel: ObservableObject {
    @Published var workplace: String
    @Published var startsAt: Date
    @Published var endsAt: Date
    @Published var note: String
    @Published var errorMessage: String?

    private let addShift: AddRosteredShift

    init(repository: ScheduleRepository, initialNote: String = "") {
        self.addShift = AddRosteredShift(repository: repository)
        let now = Date()
        self.workplace = ""
        self.startsAt = now
        self.endsAt = now.addingTimeInterval(4 * 60 * 60)
        self.note = initialNote
    }

    func save() -> Bool {
        let shift = RosteredShift(id: UUID(), workplace: workplace, startsAt: startsAt, endsAt: endsAt, note: note)
        do {
            try addShift.execute(shift)
            WidgetCenter.shared.reloadAllTimelines()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
