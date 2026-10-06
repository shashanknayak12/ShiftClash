//
//  DeadlineClash.swift
//  ShiftClash
//
//  Created by Shashank Nayak on 5/10/2026.
//

import Foundation

// calculated when we check a shift against a task due dat and it os nmot store
// Represents a shift that falls inside the 48 hour window before a assesment deadline
struct DeadlineClash: Equatable {
    var shift: RosteredShift
    var task: AssessmentTask
    var freeStudyHours: Double
}
