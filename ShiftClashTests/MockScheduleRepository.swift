//
//  MockScheduleRepository.swift
//  ShiftClashTests
//
//  Created by Shashank Nayak on 6/10/2026.
//

import Foundation
@testable import ShiftClash

final class MockScheduleRepository: ScheduleRepository {
    var subjectsList: [Subject] = []
    var tasksList: [AssessmentTask] = []
    var shiftsList: [RosteredShift] = []

    func subjects() throws -> [Subject] {
        subjectsList
    }

    func addSubject(_ subject: Subject) throws {
        subjectsList.append(subject)
    }

    func subject(withId id: UUID) throws -> Subject? {
        subjectsList.first { $0.id == id }
    }

    func assessmentTasks() throws -> [AssessmentTask] {
        tasksList
    }

    func unsubmittedTasks(dueBetween start: Date, and end: Date) throws -> [AssessmentTask] {
        tasksList.filter { !$0.isSubmitted && $0.dueDate >= start && $0.dueDate <= end }
    }

    func save(_ task: AssessmentTask) throws {
        if let index = tasksList.firstIndex(where: { $0.id == task.id }) {
            tasksList[index] = task
        } else {
            tasksList.append(task)
        }
    }

    func remove(_ task: AssessmentTask) throws {
        tasksList.removeAll { $0.id == task.id }
    }

    func rosteredShifts() throws -> [RosteredShift] {
        shiftsList
    }

    func shifts(overlapping start: Date, and end: Date) throws -> [RosteredShift] {
        shiftsList.filter { $0.startsAt < end && $0.endsAt > start }
    }

    func save(_ shift: RosteredShift) throws {
        if let index = shiftsList.firstIndex(where: { $0.id == shift.id }) {
            shiftsList[index] = shift
        } else {
            shiftsList.append(shift)
        }
    }

    func remove(_ shift: RosteredShift) throws {
        shiftsList.removeAll { $0.id == shift.id }
    }
}
