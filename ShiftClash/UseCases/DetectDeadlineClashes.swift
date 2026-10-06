//
//  DetectDeadlineClashes.swift
//  ShiftClash
//
//  Created by Shashank Nayak on 6/10/2026.
//

import Foundation

enum ClashError: LocalizedError {
    case scheduleUnavailable

    var errorDescription: String? {
        switch self {
        case .scheduleUnavailable:
            return "Could not check your roster against your deadlines right now. Try again in a moment."
        }
    }
}

struct DetectDeadlineClashes {
    private let repository: ScheduleRepository
    private let now: () -> Date

    init(repository: ScheduleRepository, now: @escaping () -> Date = Date.init) {
        self.repository = repository
        self.now = now
    }

    func execute() throws -> [DeadlineClash] {
        let currentTime = now()
        let farFuture = currentTime.addingTimeInterval(365 * 24 * 60 * 60)

        let tasks: [AssessmentTask]
        do {
            tasks = try repository.unsubmittedTasks(dueBetween: currentTime, and: farFuture)
        } catch {
            throw ClashError.scheduleUnavailable
        }

        var clashes: [DeadlineClash] = []

        for task in tasks {
            let windowStart = task.dueDate.addingTimeInterval(-48 * 60 * 60)
            let shiftsInWindow: [RosteredShift]
            do {
                shiftsInWindow = try repository.shifts(overlapping: windowStart, and: task.dueDate)
            } catch {
                throw ClashError.scheduleUnavailable
            }

            let rosteredSeconds = shiftsInWindow.reduce(0.0) { total, shift in
                total + shift.endsAt.timeIntervalSince(shift.startsAt)
            }
            let hoursUntilDue = task.dueDate.timeIntervalSince(currentTime) / 3600
            let rosteredHours = rosteredSeconds / 3600
            let freeStudyHours = max(0, hoursUntilDue - rosteredHours)

            for shift in shiftsInWindow {
                clashes.append(DeadlineClash(shift: shift, task: task, freeStudyHours: freeStudyHours))
            }
        }

        return clashes
    }
}
