//
//  ThisWeekViewModel.swift
//  ShiftClash
//
//  Created by Shashank Nayak on 7/10/2026.
//

import Foundation
import Combine
import WidgetKit

@MainActor
final class ThisWeekViewModel: ObservableObject {
    @Published var shifts: [RosteredShift] = []
    @Published var tasks: [AssessmentTask] = []
    @Published var clashes: [DeadlineClash] = []
    @Published var errorMessage: String?

    private let repository: ScheduleRepository
    private let detectClashes: DetectDeadlineClashes

    init(repository: ScheduleRepository) {
        self.repository = repository
        self.detectClashes = DetectDeadlineClashes(repository: repository)
    }

    var headlineFreeStudyHours: Double? {
        clashes.map(\.freeStudyHours).min()
    }

    func load() {
        do {
            shifts = try repository.rosteredShifts().sorted { $0.startsAt < $1.startsAt }
            tasks = try repository.assessmentTasks().sorted { $0.dueDate < $1.dueDate }
            clashes = try detectClashes.execute()
        } catch {
            errorMessage = "Could not load your roster and deadlines. Pull to refresh to try again."
        }
    }

    func deleteShift(_ shift: RosteredShift) {
        do {
            try repository.remove(shift)
            WidgetCenter.shared.reloadAllTimelines()
            load()
        } catch {
            errorMessage = "Could not remove this shift. Try again."
        }
    }

    func deleteTask(_ task: AssessmentTask) {
        do {
            try repository.remove(task)
            WidgetCenter.shared.reloadAllTimelines()
            load()
        } catch {
            errorMessage = "Could not remove this task. Try again."
        }
    }
}
