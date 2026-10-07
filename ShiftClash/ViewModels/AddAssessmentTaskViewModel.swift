//
//  AddAssessmentTaskViewModel.swift
//  ShiftClash
//
//  Created by Shashank Nayak on 7/10/2026.
//

import Foundation
import Combine
import WidgetKit

@MainActor
final class AddAssessmentTaskViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var dueDate: Date = Date().addingTimeInterval(7 * 24 * 60 * 60)
    @Published var weightPercent: Int = 20
    @Published var selectedSubjectID: UUID?
    @Published var subjects: [Subject] = []
    @Published var errorMessage: String?

    private let repository: ScheduleRepository
    private let scheduleTask: ScheduleAssessmentTask

    init(repository: ScheduleRepository) {
        self.repository = repository
        self.scheduleTask = ScheduleAssessmentTask(repository: repository)
    }

    func loadSubjects() {
        subjects = (try? repository.subjects()) ?? []
        if selectedSubjectID == nil {
            selectedSubjectID = subjects.first?.id
        }
    }

    func save() -> Bool {
        guard let subjectID = selectedSubjectID else {
            errorMessage = AssessmentError.noSubjectChosen.errorDescription
            return false
        }
        let task = AssessmentTask(id: UUID(), subjectID: subjectID, title: title, dueDate: dueDate, weightPercent: weightPercent, isSubmitted: false)
        do {
            try scheduleTask.execute(task)
            WidgetCenter.shared.reloadAllTimelines()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
