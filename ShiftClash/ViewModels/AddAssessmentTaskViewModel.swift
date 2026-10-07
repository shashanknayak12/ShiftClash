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
    @Published var title: String
    @Published var dueDate: Date
    @Published var weightPercent: Int
    @Published var selectedSubjectID: UUID?
    @Published var subjects: [Subject] = []
    @Published var errorMessage: String?
    let isEditing: Bool

    private let repository: ScheduleRepository
    private let scheduleTask: ScheduleAssessmentTask
    private let taskID: UUID
    private let isSubmitted: Bool

    init(repository: ScheduleRepository, editing task: AssessmentTask? = nil) {
        self.repository = repository
        self.scheduleTask = ScheduleAssessmentTask(repository: repository)
        if let task {
            self.taskID = task.id
            self.title = task.title
            self.dueDate = task.dueDate
            self.weightPercent = task.weightPercent
            self.selectedSubjectID = task.subjectID
            self.isSubmitted = task.isSubmitted
            self.isEditing = true
        } else {
            self.taskID = UUID()
            self.title = ""
            self.dueDate = Date().addingTimeInterval(7 * 24 * 60 * 60)
            self.weightPercent = 20
            self.selectedSubjectID = nil
            self.isSubmitted = false
            self.isEditing = false
        }
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
        let task = AssessmentTask(id: taskID, subjectID: subjectID, title: title, dueDate: dueDate, weightPercent: weightPercent, isSubmitted: isSubmitted)
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
