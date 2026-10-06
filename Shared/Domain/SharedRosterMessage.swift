//
//  SharedRosterMessage.swift
//  ShiftClash
//
//  Created by Shashank Nayak on 5/10/2026.
//

import Foundation

// A message saved by the share extension (example a roster text or a Canvas link)
// waiting in the Roster Inbox for the student to turn into a shift or dismis
struct SharedRosterMessage: Identifiable, Equatable, Codable {
    let id: UUID
    var text: String
    var receivedAt: Date
}
