//
//  AppGroup.swift
//  ShiftClash
//
//  Created by Shashank Nayak on 5/10/2026.
//

import Foundation

enum AppGroup {
    // Must match the App Group id set on the app, widget, and share extension targets.
    static let identifier = "group.com.shashank.shiftclash"

    // Shared folder the app, widget, and share extension all read/write to.
    static var containerURL: URL {
        guard let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier) else {
            fatalError("App Group '\(identifier)' not found — check it's enabled on every target.")
        }
        return url
    }
}
