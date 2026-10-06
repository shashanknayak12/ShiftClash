//
//  CoreDataScheduleRepository.swift
//  ShiftClash
//
//  Created by Shashank Nayak on 6/10/2026.
//

import CoreData


enum CoreDataRepositoryError: Error {
    case relatedSubjectNotFound
    case corruptedRecord
}

final class CoreDataScheduleRepository: ScheduleRepository {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }

    // Subjects

    func subjects() throws -> [Subject] {
        let request = SubjectEntity.fetchRequest()
        let entities = try context.fetch(request)
        return try entities.map(makeSubject)
    }

    func addSubject(_ subject: Subject) throws {
        let entity = SubjectEntity(context: context)
        entity.id = subject.id
        entity.code = subject.code
        entity.name = subject.name
        try context.save()
    }

    func subject(withId id: UUID) throws -> Subject? {
        let request = SubjectEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        guard let entity = try context.fetch(request).first else { return nil }
        return try makeSubject(from: entity)
    }

    // Assessment tasks

    func assessmentTasks() throws -> [AssessmentTask] {
        let request = AssessmentTaskEntity.fetchRequest()
        let entities = try context.fetch(request)
        return try entities.map(makeAssessmentTask)
    }


    func unsubmittedTasks(dueBetween start: Date, and end: Date) throws -> [AssessmentTask] {
        let request = AssessmentTaskEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "isSubmitted == NO AND dueDate >= %@ AND dueDate <= %@",
            start as NSDate, end as NSDate
        )
        let entities = try context.fetch(request)
        return try entities.map(makeAssessmentTask)
    }

    func save(_ task: AssessmentTask) throws {
        let request = AssessmentTaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", task.id as CVarArg)
        request.fetchLimit = 1
        let entity = try context.fetch(request).first ?? AssessmentTaskEntity(context: context)

        entity.id = task.id
        entity.title = task.title
        entity.dueDate = task.dueDate
        entity.weightPercent = Int16(task.weightPercent)
        entity.isSubmitted = task.isSubmitted

        let subjectRequest = SubjectEntity.fetchRequest()
        subjectRequest.predicate = NSPredicate(format: "id == %@", task.subjectID as CVarArg)
        subjectRequest.fetchLimit = 1
        guard let subjectEntity = try context.fetch(subjectRequest).first else {
            throw CoreDataRepositoryError.relatedSubjectNotFound
        }
        entity.subject = subjectEntity

        try context.save()
    }

    // Rostered shifts

    func rosteredShifts() throws -> [RosteredShift] {
        let request = RosteredShiftEntity.fetchRequest()
        let entities = try context.fetch(request)
        return try entities.map(makeRosteredShift)
    }

    // Shifts that fall inside a given time window. A shift overlaps the
    // window when it starts before the window ends and ends after the
    // window starts. This is the real question AddRosteredShift and
    // DetectDeadlineClashes need answered.
    func shifts(overlapping start: Date, and end: Date) throws -> [RosteredShift] {
        let request = RosteredShiftEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "startsAt < %@ AND endsAt > %@",
            end as NSDate, start as NSDate
        )
        let entities = try context.fetch(request)
        return try entities.map(makeRosteredShift)
    }

    func save(_ shift: RosteredShift) throws {
        let request = RosteredShiftEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", shift.id as CVarArg)
        request.fetchLimit = 1
        let entity = try context.fetch(request).first ?? RosteredShiftEntity(context: context)

        entity.id = shift.id
        entity.workplace = shift.workplace
        entity.startsAt = shift.startsAt
        entity.endsAt = shift.endsAt
        entity.note = shift.note

        try context.save()
    }

    func remove(_ shift: RosteredShift) throws {
        let request = RosteredShiftEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", shift.id as CVarArg)
        request.fetchLimit = 1
        guard let entity = try context.fetch(request).first else { return }
        context.delete(entity)
        try context.save()
    }

    // Mapping between Core Data objects and plain structs

    // These check for missing data instead of assuming it is always there.
    // A nil here would mean the stored record is incomplete or corrupted,
    // not a normal case, so we throw a clear error instead of crashing.

    private func makeSubject(from entity: SubjectEntity) throws -> Subject {
        guard let id = entity.id, let code = entity.code, let name = entity.name else {
            throw CoreDataRepositoryError.corruptedRecord
        }
        return Subject(id: id, code: code, name: name)
    }

    private func makeAssessmentTask(from entity: AssessmentTaskEntity) throws -> AssessmentTask {
        guard let id = entity.id,
              let subjectID = entity.subject?.id,
              let title = entity.title,
              let dueDate = entity.dueDate else {
            throw CoreDataRepositoryError.corruptedRecord
        }
        return AssessmentTask(
            id: id,
            subjectID: subjectID,
            title: title,
            dueDate: dueDate,
            weightPercent: Int(entity.weightPercent),
            isSubmitted: entity.isSubmitted
        )
    }

    private func makeRosteredShift(from entity: RosteredShiftEntity) throws -> RosteredShift {
        guard let id = entity.id,
              let workplace = entity.workplace,
              let startsAt = entity.startsAt,
              let endsAt = entity.endsAt,
              let note = entity.note else {
            throw CoreDataRepositoryError.corruptedRecord
        }
        return RosteredShift(id: id, workplace: workplace, startsAt: startsAt, endsAt: endsAt, note: note)
    }
}

