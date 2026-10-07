//
//  ClashDetailView.swift
//  ShiftClash
//
//  Created by Shashank Nayak on 7/10/2026.
//

import SwiftUI

struct ClashDetailView: View {
    @StateObject private var viewModel: ClashDetailViewModel
    @Environment(\.dismiss) private var dismiss
    var onSubmitted: (() -> Void)?

    init(clash: DeadlineClash, repository: ScheduleRepository, onSubmitted: (() -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: ClashDetailViewModel(clash: clash, repository: repository))
        self.onSubmitted = onSubmitted
    }

    var body: some View {
        List {
            Section("Shift") {
                Text(viewModel.clash.shift.workplace).bold()
                Text(viewModel.clash.shift.startsAt, format: .dateTime.weekday(.wide).hour().minute())
                    .foregroundStyle(.secondary)
            }

            Section("Deadline") {
                Text(viewModel.clash.task.title).bold()
                Text("Due \(viewModel.clash.task.dueDate.formatted(date: .abbreviated, time: .shortened))")
                    .foregroundStyle(.secondary)
            }

            Section {
                Text("\(viewModel.clash.freeStudyHours, specifier: "%.1f") free study hours before this deadline")
                    .font(.headline)
            }

            if !viewModel.clash.task.isSubmitted {
                Section {
                    Button("Mark as Submitted") {
                        viewModel.markAsSubmitted()
                    }
                }
            }
        }
        .navigationTitle("Deadline Clash")
        .alert("Could not update this task", isPresented: .constant(viewModel.errorMessage != nil), actions: {
            Button("OK") { viewModel.errorMessage = nil }
        }, message: {
            Text(viewModel.errorMessage ?? "")
        })
        .onChange(of: viewModel.didSubmit) { _, didSubmit in
            if didSubmit {
                onSubmitted?()
                dismiss()
            }
        }
    }
}
