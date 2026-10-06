//
//  SubmitAssessmentTask.swift .swift
//  ShiftClash
//
//  Created by Shashank Nayak on 6/10/2026.
//

import Foundation

enum SubmissionError: LocalizedError {
    case alreadySubmitted

    var errorDescription: String? {
        switch self {
        case .alreadySubmitted:
            return "This task is already marked as submitted."
        }
    }
}

struct SubmitAssessmentTask {
    private let repository: ScheduleRepository

    init(repository: ScheduleRepository) {
        self.repository = repository
    }

    func execute(_ task: AssessmentTask) throws {
        guard !task.isSubmitted else {
            throw SubmissionError.alreadySubmitted
        }

        var submittedTask = task
        submittedTask.isSubmitted = true
        try repository.save(submittedTask)
    }
}
