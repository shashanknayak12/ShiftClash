//
//  SubjectsViewModel.swift
//  ShiftClash
//
//  Created by Shashank Nayak on 7/10/2026.
//

import Foundation
import Combine

@MainActor
final class SubjectsViewModel: ObservableObject {
    @Published var subjects: [Subject] = []
    @Published var tasks: [AssessmentTask] = []
    @Published var errorMessage: String?

    private let repository: ScheduleRepository

    init(repository: ScheduleRepository) {
        self.repository = repository
    }

    func load() {
        do {
            subjects = try repository.subjects()
            tasks = try repository.assessmentTasks()
        } catch {
            errorMessage = "Could not load your subjects. Try again."
        }
    }

    func tasks(for subject: Subject) -> [AssessmentTask] {
        tasks.filter { $0.subjectID == subject.id }
    }

    func addSubject(code: String, name: String) {
        let subject = Subject(id: UUID(), code: code, name: name)
        do {
            try repository.addSubject(subject)
            load()
        } catch {
            errorMessage = "Could not save this subject. Try again."
        }
    }
}
