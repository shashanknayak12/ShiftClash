//
//  ScheduleUseCaseTests.swift
//  ShiftClashTests
//
//  Created by Shashank Nayak on 6/10/2026.
//

import Testing
import Foundation
@testable import ShiftClash

struct ScheduleUseCaseTests {

    @Test func addingShift_thatOverlapsAnExistingShift_isRejected() throws {
        let repository = MockScheduleRepository()
        let existing = RosteredShift(id: UUID(), workplace: "Cafe", startsAt: date("2026-10-10 09:00"), endsAt: date("2026-10-10 17:00"), note: "")
        repository.shiftsList = [existing]
        let useCase = AddRosteredShift(repository: repository)
        let overlapping = RosteredShift(id: UUID(), workplace: "Servo", startsAt: date("2026-10-10 12:00"), endsAt: date("2026-10-10 20:00"), note: "")

        #expect(throws: RosterError.self) {
            try useCase.execute(overlapping)
        }
    }

    @Test func addingShift_thatEndsBeforeItStarts_isRejected() throws {
        let repository = MockScheduleRepository()
        let useCase = AddRosteredShift(repository: repository)
        let shift = RosteredShift(id: UUID(), workplace: "Cafe", startsAt: date("2026-10-10 17:00"), endsAt: date("2026-10-10 09:00"), note: "")

        #expect(throws: RosterError.self) {
            try useCase.execute(shift)
        }
    }

    @Test func addingShift_ofExactlyTwelveHours_isAccepted() throws {
        let repository = MockScheduleRepository()
        let useCase = AddRosteredShift(repository: repository)
        let shift = RosteredShift(id: UUID(), workplace: "Cafe", startsAt: date("2026-10-10 06:00"), endsAt: date("2026-10-10 18:00"), note: "")

        try useCase.execute(shift)

        #expect(repository.shiftsList.count == 1)
    }

    @Test func schedulingTask_withDueDateInThePast_isRejected() throws {
        let repository = MockScheduleRepository()
        let subject = Subject(id: UUID(), code: "COMP301", name: "Mobile Development")
        repository.subjectsList = [subject]
        let useCase = ScheduleAssessmentTask(repository: repository, now: { date("2026-10-10 00:00") })
        let task = AssessmentTask(id: UUID(), subjectID: subject.id, title: "Report", dueDate: date("2026-10-01 00:00"), weightPercent: 20, isSubmitted: false)

        #expect(throws: AssessmentError.self) {
            try useCase.execute(task)
        }
    }

    @Test func schedulingTask_withValidDetails_isSaved() throws {
        let repository = MockScheduleRepository()
        let subject = Subject(id: UUID(), code: "COMP301", name: "Mobile Development")
        repository.subjectsList = [subject]
        let useCase = ScheduleAssessmentTask(repository: repository, now: { date("2026-10-01 00:00") })
        let task = AssessmentTask(id: UUID(), subjectID: subject.id, title: "Report", dueDate: date("2026-10-10 00:00"), weightPercent: 20, isSubmitted: false)

        try useCase.execute(task)

        #expect(repository.tasksList.count == 1)
        
    }

    @Test func shiftStartingExactly48HoursBeforeDeadline_isAClash() throws {
        let repository = MockScheduleRepository()
        let subject = Subject(id: UUID(), code: "COMP301", name: "Mobile Development")
        let dueDate = date("2026-10-12 09:00")
        let task = AssessmentTask(id: UUID(), subjectID: subject.id, title: "Report", dueDate: dueDate, weightPercent: 20, isSubmitted: false)
        let shiftStart = dueDate.addingTimeInterval(-48 * 60 * 60)
        let shift = RosteredShift(id: UUID(), workplace: "Cafe", startsAt: shiftStart, endsAt: shiftStart.addingTimeInterval(4 * 60 * 60), note: "")
        repository.subjectsList = [subject]
        repository.tasksList = [task]
        repository.shiftsList = [shift]

        let useCase = DetectDeadlineClashes(repository: repository, now: { date("2026-10-10 09:00") })
        let clashes = try useCase.execute()

        #expect(clashes.contains { $0.shift.id == shift.id && $0.task.id == task.id })
    }

    @Test func shiftBeforeAnAlreadySubmittedTask_isNotAClash() throws {
        let repository = MockScheduleRepository()
        let subject = Subject(id: UUID(), code: "COMP301", name: "Mobile Development")
        let dueDate = date("2026-10-12 09:00")
        let task = AssessmentTask(id: UUID(), subjectID: subject.id, title: "Report", dueDate: dueDate, weightPercent: 20, isSubmitted: true)
        let shiftStart = dueDate.addingTimeInterval(-24 * 60 * 60)
        let shift = RosteredShift(id: UUID(), workplace: "Cafe", startsAt: shiftStart, endsAt: shiftStart.addingTimeInterval(4 * 60 * 60), note: "")
        repository.subjectsList = [subject]
        repository.tasksList = [task]
        repository.shiftsList = [shift]

        let useCase = DetectDeadlineClashes(repository: repository, now: { date("2026-10-10 09:00") })
        let clashes = try useCase.execute()

        #expect(clashes.isEmpty)
    }

    @Test func freeStudyHours_subtractsRosteredHoursBeforeDeadline() throws {
        let repository = MockScheduleRepository()
        let subject = Subject(id: UUID(), code: "COMP301", name: "Mobile Development")
        let now = date("2026-10-10 09:00")
        let dueDate = now.addingTimeInterval(48 * 60 * 60)
        let task = AssessmentTask(id: UUID(), subjectID: subject.id, title: "Report", dueDate: dueDate, weightPercent: 20, isSubmitted: false)
        let shift = RosteredShift(id: UUID(), workplace: "Cafe", startsAt: now, endsAt: now.addingTimeInterval(8 * 60 * 60), note: "")
        repository.subjectsList = [subject]
        repository.tasksList = [task]
        repository.shiftsList = [shift]

        let useCase = DetectDeadlineClashes(repository: repository, now: { now })
        let clashes = try useCase.execute()

        let clash = try #require(clashes.first)
        #expect(clash.freeStudyHours == 40)
    }

    @Test func submittingTask_twice_isRejected() throws {
        let repository = MockScheduleRepository()
        let task = AssessmentTask(id: UUID(), subjectID: UUID(), title: "Report", dueDate: date("2026-10-10 00:00"), weightPercent: 20, isSubmitted: true)
        repository.tasksList = [task]
        let useCase = SubmitAssessmentTask(repository: repository)

        #expect(throws: SubmissionError.self) {
            try useCase.execute(task)
        }
    }
}

private func date(_ string: String) -> Date {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm"
    return formatter.date(from: string)!
}
