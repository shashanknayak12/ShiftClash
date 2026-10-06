//
//  AddRosteredShift.swift .swift
//  ShiftClash
//
//  Created by Shashank Nayak on 6/10/2026.
//

import Foundation

enum RosterError: LocalizedError {
    case shiftEndsBeforeItStarts
    case shiftTooLong
    case overlapsExistingShift(RosteredShift)

    var errorDescription: String? {
        switch self {
        case .shiftEndsBeforeItStarts:
            return "This shift ends before it starts. Check the start and end times."
        case .shiftTooLong:
            return "This shift is longer than 12 hours. Split it into two shifts or check the times."
        case .overlapsExistingShift(let shift):
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            let when = formatter.string(from: shift.startsAt)
            return "This shift overlaps your \(shift.workplace) shift starting \(when). Change the times or remove the other shift."
        }
    }
}

struct AddRosteredShift {
    private let repository: ScheduleRepository

    init(repository: ScheduleRepository) {
        self.repository = repository
    }

    func execute(_ shift: RosteredShift) throws {
        guard shift.endsAt > shift.startsAt else {
            throw RosterError.shiftEndsBeforeItStarts
        }

        let duration = shift.endsAt.timeIntervalSince(shift.startsAt)
        guard duration <= 12 * 60 * 60 else {
            throw RosterError.shiftTooLong
        }

        let overlapping = try repository.shifts(overlapping: shift.startsAt, and: shift.endsAt)
        if let clash = overlapping.first(where: { $0.id != shift.id }) {
            throw RosterError.overlapsExistingShift(clash)
        }

        try repository.save(shift)
    }
}
