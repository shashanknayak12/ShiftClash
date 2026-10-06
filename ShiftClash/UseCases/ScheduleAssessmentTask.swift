//
//  ScheduleAssessmentTask.swift
//  ShiftClash
//
//  Created by Shashank Nayak on 6/10/2026.
//

import Foundation

enum AssessmentError: LocalizedError {
    case missingTitle
    case dueDateAlreadyPassed
    case invalidWeight
    case noSubjectChosen

    var errorDescription: String? {
        switch self {
        case .missingTitle:
            return "This task needs a title before it can be saved."
        case .dueDateAlreadyPassed:
            return "This due date has already passed. Check the date or pick a date in the future."
        case .invalidWeight:
            return "Weight must be a number between 1 and 100."
        case .noSubjectChosen:
            return "Choose a subject for this task before saving it."
        }
    }
}

struct ScheduleAssessmentTask {
    private let repository: ScheduleRepository
    private let now: () -> Date

    init(repository: ScheduleRepository, now: @escaping () -> Date = Date.init) {
        self.repository = repository
        self.now = now
    }

    func execute(_ task: AssessmentTask) throws {
        guard !task.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AssessmentError.missingTitle
        }

        guard task.dueDate > now() else {
            throw AssessmentError.dueDateAlreadyPassed
        }

        guard (1...100).contains(task.weightPercent) else {
            throw AssessmentError.invalidWeight
        }

        guard try repository.subject(withId: task.subjectID) != nil else {
            throw AssessmentError.noSubjectChosen
        }

        try repository.save(task)
    }
}
