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
    @State private var shiftToEdit: RosteredShift?
    @State private var taskToEdit: AssessmentTask?

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
                        headlineCard(hours: hours)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
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
            .listStyle(.insetGrouped)
            .navigationTitle("This Week")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button("Add Shift", systemImage: "briefcase") { showingAddShift = true }
                        Button("Add Assessment Task", systemImage: "doc.text") { showingAddTask = true }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddShift, onDismiss: viewModel.load) {
                AddShiftView(repository: repository)
            }
            .sheet(isPresented: $showingAddTask, onDismiss: viewModel.load) {
                AddAssessmentTaskView(repository: repository)
            }
            .sheet(item: $shiftToEdit, onDismiss: viewModel.load) { shift in
                AddShiftView(repository: repository, editing: shift)
            }
            .sheet(item: $taskToEdit, onDismiss: viewModel.load) { task in
                AddAssessmentTaskView(repository: repository, editing: task)
            }
            .onAppear(perform: viewModel.load)
        }
    }

    private func headlineCard(hours: Double) -> some View {
        let isTight = hours < 5
        return VStack(alignment: .leading, spacing: 6) {
            Label("\(hours, specifier: "%.1f") free study hours", systemImage: isTight ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                .font(.title2.bold())
            Text("before your next clashing deadline")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.85))
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            LinearGradient(
                colors: isTight ? [.red, .orange] : [.indigo, .blue],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.vertical, 6)
    }

    @ViewBuilder
    private func shiftRow(_ shift: RosteredShift) -> some View {
        if let clash = viewModel.clashes.first(where: { $0.shift.id == shift.id }) {
            NavigationLink {
                ClashDetailView(clash: clash, repository: repository, onSubmitted: viewModel.load)
            } label: {
                shiftLabel(shift, isClash: true)
            }
            .listRowBackground(Color.orange.opacity(0.1))
            .swipeActions(edge: .trailing) {
                Button("Delete", systemImage: "trash", role: .destructive) {
                    viewModel.deleteShift(shift)
                }
            }
        } else {
            Button {
                shiftToEdit = shift
            } label: {
                shiftLabel(shift, isClash: false)
            }
            .buttonStyle(.plain)
            .swipeActions(edge: .trailing) {
                Button("Delete", systemImage: "trash", role: .destructive) {
                    viewModel.deleteShift(shift)
                }
            }
        }
    }

    private func shiftLabel(_ shift: RosteredShift, isClash: Bool) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "briefcase.fill")
                .font(.title3)
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(isClash ? Color.orange : Color.indigo)
                .clipShape(Circle())
                .shadow(color: (isClash ? Color.orange : Color.indigo).opacity(0.35), radius: 4, y: 2)

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(shift.workplace).bold()
                    if isClash {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                            .font(.caption)
                    }
                }
                Text(shift.startsAt, format: .dateTime.weekday(.wide).hour().minute())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private func taskRow(_ task: AssessmentTask) -> some View {
        if let clash = viewModel.clashes.first(where: { $0.task.id == task.id }) {
            NavigationLink {
                ClashDetailView(clash: clash, repository: repository, onSubmitted: viewModel.load)
            } label: {
                taskLabel(task, isClash: true)
            }
            .listRowBackground(Color.orange.opacity(0.1))
            .swipeActions(edge: .trailing) {
                Button("Delete", systemImage: "trash", role: .destructive) {
                    viewModel.deleteTask(task)
                }
            }
        } else {
            Button {
                taskToEdit = task
            } label: {
                taskLabel(task, isClash: false)
            }
            .buttonStyle(.plain)
            .listRowBackground(task.isSubmitted ? Color.green.opacity(0.08) : Color(.secondarySystemGroupedBackground))
            .swipeActions(edge: .trailing) {
                Button("Delete", systemImage: "trash", role: .destructive) {
                    viewModel.deleteTask(task)
                }
            }
        }
    }

    private func taskLabel(_ task: AssessmentTask, isClash: Bool) -> some View {
        HStack(spacing: 12) {
            Image(systemName: task.isSubmitted ? "checkmark.seal.fill" : "doc.text.fill")
                .font(.title3)
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(task.isSubmitted ? Color.green : (isClash ? Color.orange : Color.blue))
                .clipShape(Circle())
                .shadow(color: (task.isSubmitted ? Color.green : (isClash ? Color.orange : Color.blue)).opacity(0.35), radius: 4, y: 2)

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(task.title).bold()
                    if isClash {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                            .font(.caption)
                    }
                }
                Text("Due \(task.dueDate.formatted(date: .abbreviated, time: .shortened))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
