# ShiftClash

An iOS app that helps a full-time university student working casual rostered shifts spot when a shift lands inside the 48 hours before an assignment is due  before it's too late to do anything about it.

## Domain context

Casual retail and hospitality shifts in Australia are often published with as little as 24–48 hours notice. A student juggling a roster and assignment deadlines can easily miss that a shift collides with a deadline until the night before. ShiftClash stores the student's rostered shifts and assessment tasks, automatically detects when a shift falls inside the 48-hour window before an unsubmitted deadline, and shows how many free study hours are actually left.

## Architecture

MVVM with a Use Case layer and a Repository protocol, following strict one-way dependencies:

```
View → ViewModel → Use Case → Repository (protocol) → Core Data
```

- **Domain models** (`Shared/Domain`) — `Subject`, `AssessmentTask`, `RosteredShift`, `DeadlineClash`, `SharedRosterMessage`. Plain Swift structs, no Core Data types anywhere outside the repository.
- **Use Cases** (`ShiftClash/UseCases`) — `AddRosteredShift`, `ScheduleAssessmentTask`, `DetectDeadlineClashes`, `SubmitAssessmentTask`. Each enforces a real business rule and throws a typed, human-readable error.
- **Repository** (`Shared/Repositories/ScheduleRepository.swift`) — a protocol, implemented by `CoreDataScheduleRepository`. Views and ViewModels never touch Core Data directly.
- **ViewModels / Views** (`ShiftClash/ViewModels`, `ShiftClash/Views`) — 6 screens: This Week, Add Shift, Add Assessment Task, Clash Detail, Subjects, Roster Inbox.

## Database — Core Data

Core Data was chosen over CloudKit because this data (one student's shifts and tasks) is private to that student, never shared or synced to other users, and needs to be fast and available offline — exactly what Core Data is built for. The store lives inside the App Group container so the app, widget, and share extension can all read and write the same data.

Schema: `Subject` has many `AssessmentTask` (cascade delete), `AssessmentTask` belongs to one `Subject`, `RosteredShift` stands alone. Two real domain queries: tasks unsubmitted and due in a date range, and shifts overlapping a time window.

## Extensions

- **WidgetKit widget** — shows the next shift, next deadline, and any clash warning with free study hours. Supports Home Screen (small, medium) and Lock Screen (`.accessoryRectangular`) families, reading the same Core Data store through the App Group. The app calls `WidgetCenter.shared.reloadAllTimelines()` after every change.
- **Share Extension** — accepts shared text and web links (roster messages, Canvas links) from any app, saves them as a `SharedRosterMessage` into the App Group, and the Roster Inbox screen lets the student turn one into a shift or dismiss it.

## App Group

`group.com.shashank.shiftclash`

## Setup

1. Open `ShiftClash.xcodeproj` in Xcode.
2. Confirm the App Groups capability (`group.com.shashank.shiftclash`) is enabled on the `ShiftClash`, `ShiftClashWidgetExtension`, and `ShiftClashShare` targets under Signing & Capabilities.
3. Build and run the `ShiftClash` scheme on a Simulator or device.
4. To see the widget: add it from the Home Screen or Lock Screen widget gallery after running the app once.
5. To test the share extension: share any text or link from Safari/Notes and choose ShiftClashShare.

## Tests

9 unit tests in `ShiftClashTests`, using `MockScheduleRepository` (in-memory, no Core Data), covering boundary conditions, and domain error cases for all 4 Use Cases.
