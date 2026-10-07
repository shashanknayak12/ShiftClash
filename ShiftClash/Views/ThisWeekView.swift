//
//  ThisWeekView.swift
//  ShiftClash
//
//  Created by Shashank Nayak on 7/10/2026.
//

import SwiftUI

struct ThisWeekView: View {
    @StateObject private var viewModel: ThisWeekViewModel
    @State private var showingAddShift = false
    @State private var showingAddTask = false

    private let repository: ScheduleRepository

    init(repository: ScheduleRepository) {
        self.repository = repository
        _viewModel = StateObject(wrappedValue: ThisWeekViewModel(repository: repository))
    }

    var body: some View {
        NavigationStack {
            List {
                if let hours = viewModel.headlineFreeStudyHours {
                    Section {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(hours, specifier: "%.1f") free study hours")
                                .font(.title2.bold())
                            Text("before your next clashing deadline")
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                if viewModel.shifts.isEmpty && viewModel.tasks.isEmpty {
                    ContentUnavailableView(
                        "No shifts or assessments yet.",
                        systemImage: "calendar",
                        description: Text("Add your roster to check for clashes.")
                    )
                } else {
                    Section("Shifts") {
                        ForEach(viewModel.shifts) { shift in
                            shiftRow(shift)
                        }
                    }
                    Section("Assessment Tasks") {
                        ForEach(viewModel.tasks) { task in
                            taskRow(task)
                        }
                    }
                }
            }
            .navigationTitle("This Week")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button("Add Shift") { showingAddShift = true }
                        Button("Add Assessment Task") { showingAddTask = true }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddShift, onDismiss: viewModel.load) {
                AddShiftView(repository: repository)
            }
            .sheet(isPresented: $showingAddTask, onDismiss: viewModel.load) {
                AddAssessmentTaskView(repository: repository)
            }
            .onAppear(perform: viewModel.load)
        }
    }

    @ViewBuilder
    private func shiftRow(_ shift: RosteredShift) -> some View {
        if let clash = viewModel.clashes.first(where: { $0.shift.id == shift.id }) {
            NavigationLink {
                ClashDetailView(clash: clash, repository: repository, onSubmitted: viewModel.load)
            } label: {
                shiftLabel(shift, isClash: true)
            }
        } else {
            shiftLabel(shift, isClash: false)
        }
    }

    private func shiftLabel(_ shift: RosteredShift, isClash: Bool) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text(shift.workplace).bold()
                if isClash {
                    Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.orange)
                }
            }
            Text(shift.startsAt, format: .dateTime.weekday(.wide).hour().minute())
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private func taskRow(_ task: AssessmentTask) -> some View {
        if let clash = viewModel.clashes.first(where: { $0.task.id == task.id }) {
            NavigationLink {
                ClashDetailView(clash: clash, repository: repository, onSubmitted: viewModel.load)
            } label: {
                taskLabel(task, isClash: true)
            }
        } else {
            taskLabel(task, isClash: false)
        }
    }

    private func taskLabel(_ task: AssessmentTask, isClash: Bool) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text(task.title).bold()
                if isClash {
                    Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.orange)
                }
            }
            Text("Due \(task.dueDate.formatted(date: .abbreviated, time: .shortened))")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}
