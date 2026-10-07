//
//  ClashDetailViewModel.swift
//  ShiftClash
//
//  Created by Shashank Nayak on 7/10/2026.
//

import Foundation
import Combine
import WidgetKit

@MainActor
final class ClashDetailViewModel: ObservableObject {
    @Published var clash: DeadlineClash
    @Published var errorMessage: String?
    @Published var didSubmit = false

    private let submitTask: SubmitAssessmentTask

    init(clash: DeadlineClash, repository: ScheduleRepository) {
        self.clash = clash
        self.submitTask = SubmitAssessmentTask(repository: repository)
    }

    func markAsSubmitted() {
        do {
            try submitTask.execute(clash.task)
            didSubmit = true
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
