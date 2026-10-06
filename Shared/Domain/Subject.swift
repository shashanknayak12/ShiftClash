//
//  Subject.swift
//  ShiftClash
//
//  Created by Shashank Nayak on 5/10/2026.
//

import Foundation
// A subject is that the student is enrolled in exampkle "40005 Advanced iOS Development"
// Here every AssessmentTask belongs to one of these.
  struct Subject: Identifiable, Equatable {
      let id: UUID
      var code: String
      var name: String
  }
