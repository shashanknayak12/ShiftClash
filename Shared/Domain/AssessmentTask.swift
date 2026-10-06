//
//  AssessmentTask.swift
//  ShiftClash
//
//  Created by Shashank Nayak on 5/10/2026.
//

import Foundation
// assessment with a due date, belonging to one Subject.
struct AssessmentTask: Identifiable, Equatable {
      let id: UUID
      var subjectID: UUID
      var title: String
      var dueDate: Date
      var weightPercent: Int
      var isSubmitted: Bool
    }
