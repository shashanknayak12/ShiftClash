//
//  RosteredShift.swift
//  ShiftClash
//
//  Created by Shashank Nayak on 5/10/2026.
//

import Foundation

//  rostered work shift
struct RosteredShift: Identifiable, Equatable {
    let id: UUID
    var workplace: String
    var startsAt: Date
    var endsAt: Date
    var note: String
}
