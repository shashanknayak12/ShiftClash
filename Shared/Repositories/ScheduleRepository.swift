//
//  ScheduleRepository.swift
//  ShiftClash
//
//  Created by Shashank Nayak on 6/10/2026.
//

import Foundation

protocol ScheduleRepository {
    func subjects() throws -> [Subject]
    func addSubject(_ subject: Subject) throws
    // So we can check a chosen subject actually exists.
    func subject(withId id: UUID) throws -> Subject?

    func assessmentTasks() throws -> [AssessmentTask]
    // Tasks due in a date range that have not been submitted yet.
    func unsubmittedTasks(dueBetween start: Date, and end: Date) throws -> [AssessmentTask]
    func save(_ task: AssessmentTask) throws

    func rosteredShifts() throws -> [RosteredShift]
    // Shifts that fall inside a given time window.
    func shifts(overlapping start: Date, and end: Date) throws -> [RosteredShift]
    func save(_ shift: RosteredShift) throws
    func remove(_ shift: RosteredShift) throws
}
