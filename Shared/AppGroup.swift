//
//  AppGroup.swift
//  ShiftClash
//
//  Created by Shashank Nayak on 5/10/2026.
//

import Foundation

enum AppGroup {
    // This has to match the App Group added on the app, widget, and share extension targets.
    static let identifier = "group.com.shashank.shiftclash"

    // This is the shared folder the app, widget, and share extension can all read and write to.
    static var containerURL: URL {
        guard let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier) else {
            fatalError("App Group \(identifier) was not found. Check that it is enabled on every target.")
        }
        return url
    }
}
