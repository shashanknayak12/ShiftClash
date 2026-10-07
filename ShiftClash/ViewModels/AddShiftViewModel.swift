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
    let isEditing: Bool

    private let addShift: AddRosteredShift
    private let shiftID: UUID

    init(repository: ScheduleRepository, editing shift: RosteredShift? = nil, initialNote: String = "") {
        self.addShift = AddRosteredShift(repository: repository)
        if let shift {
            self.shiftID = shift.id
            self.workplace = shift.workplace
            self.startsAt = shift.startsAt
            self.endsAt = shift.endsAt
            self.note = shift.note
            self.isEditing = true
        } else {
            self.shiftID = UUID()
            let now = Date()
            self.workplace = ""
            self.startsAt = now
            self.endsAt = now.addingTimeInterval(4 * 60 * 60)
            self.note = initialNote
            self.isEditing = false
        }
    }

    func save() -> Bool {
        let shift = RosteredShift(id: shiftID, workplace: workplace, startsAt: startsAt, endsAt: endsAt, note: note)
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
