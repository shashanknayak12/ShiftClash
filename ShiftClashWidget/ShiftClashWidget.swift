//
//  ShiftClashWidget.swift
//  ShiftClashWidget
//
//  Created by Shashank Nayak on 5/10/2026.
//

import WidgetKit
import SwiftUI

//  widget shows the next shift, the next deadline, and the
// soonest deadline clash if there is one. Built fresh each time the
// timeline refreshes, straight from Core Data through the App Group.
struct ShiftClashEntry: TimelineEntry {
    let date: Date
    let nextShift: RosteredShift?
    let nextTask: AssessmentTask?
    let clash: DeadlineClash?
}

struct ShiftClashTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> ShiftClashEntry {
        ShiftClashEntry(date: Date(), nextShift: nil, nextTask: nil, clash: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (ShiftClashEntry) -> Void) {
        completion(makeEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ShiftClashEntry>) -> Void) {
        let entry = makeEntry()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date().addingTimeInterval(1800)
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    private func makeEntry() -> ShiftClashEntry {
        let repository = CoreDataScheduleRepository()
        let now = Date()

        let nextShift = (try? repository.rosteredShifts())?
            .filter { $0.startsAt >= now }
            .sorted { $0.startsAt < $1.startsAt }
            .first

        let nextTask = (try? repository.assessmentTasks())?
            .filter { !$0.isSubmitted && $0.dueDate >= now }
            .sorted { $0.dueDate < $1.dueDate }
            .first

        let clash = (try? DetectDeadlineClashes(repository: repository).execute())?
            .sorted { $0.task.dueDate < $1.task.dueDate }
            .first

        return ShiftClashEntry(date: now, nextShift: nextShift, nextTask: nextTask, clash: clash)
    }
}

struct ShiftClashWidgetEntryView: View {
    var entry: ShiftClashEntry
    @Environment(\.widgetFamily) private var family

    @ViewBuilder
    var body: some View {
        switch family {
        case .accessoryRectangular:
            lockScreenView
        case .systemSmall:
            smallView
        default:
            mediumView
        }
    }

    private var smallView: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let clash = entry.clash {
                Label("Clash", systemImage: "exclamationmark.triangle.fill")
                    .font(.caption.bold())
                    .foregroundStyle(.orange)
                Text(clash.task.title)
                    .font(.headline)
                    .lineLimit(2)
                Text("\(clash.freeStudyHours, specifier: "%.1f")h free")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else if let shift = entry.nextShift {
                Label("Next Shift", systemImage: "briefcase.fill")
                    .font(.caption.bold())
                    .foregroundStyle(.indigo)
                Text(shift.workplace)
                    .font(.headline)
                Text(shift.startsAt, style: .time)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Label("No clashes this week", systemImage: "checkmark.circle.fill")
                    .font(.caption.bold())
                    .foregroundStyle(.green)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var mediumView: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Label("Next Shift", systemImage: "briefcase.fill")
                        .font(.caption.bold())
                        .foregroundStyle(.indigo)
                    if let shift = entry.nextShift {
                        Text(shift.workplace).font(.subheadline.bold())
                        Text(shift.startsAt, format: .dateTime.weekday(.abbreviated).hour().minute())
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("No shifts rostered").font(.caption).foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .leading, spacing: 4) {
                    Label("Next Deadline", systemImage: "doc.text.fill")
                        .font(.caption.bold())
                        .foregroundStyle(.blue)
                    if let task = entry.nextTask {
                        Text(task.title).font(.subheadline.bold())
                        Text(task.dueDate, format: .dateTime.day().month().hour().minute())
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("No deadlines").font(.caption).foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            if let clash = entry.clash {
                Label("\(clash.freeStudyHours, specifier: "%.1f")h free before \(clash.task.title)", systemImage: "exclamationmark.triangle.fill")
                    .font(.caption2.bold())
                    .foregroundStyle(.orange)
            } else {
                Label("No clashes this week", systemImage: "checkmark.circle.fill")
                    .font(.caption2.bold())
                    .foregroundStyle(.green)
            }
        }
        .padding()
    }

    @ViewBuilder
    private var lockScreenView: some View {
        if let clash = entry.clash {
            Label("\(clash.freeStudyHours, specifier: "%.0f")h free · \(clash.task.title)", systemImage: "exclamationmark.triangle.fill")
        } else if let shift = entry.nextShift {
            Label(shift.workplace, systemImage: "briefcase.fill")
        } else {
            Label("No clashes this week", systemImage: "checkmark.circle.fill")
        }
    }
}

struct ShiftClashWidget: Widget {
    let kind: String = "ShiftClashWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ShiftClashTimelineProvider()) { entry in
            ShiftClashWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("ShiftClash")
        .description("See your next shift, next deadline, and any clashes.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular])
    }
}

#Preview(as: .systemSmall) {
    ShiftClashWidget()
} timeline: {
    ShiftClashEntry(date: .now, nextShift: nil, nextTask: nil, clash: nil)
}
