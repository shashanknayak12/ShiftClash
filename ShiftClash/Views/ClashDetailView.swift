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
            Section {
                Label {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(viewModel.clash.shift.workplace).bold()
                        Text(viewModel.clash.shift.startsAt, format: .dateTime.weekday(.wide).hour().minute())
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: "briefcase.fill")
                        .foregroundStyle(.indigo)
                }
            } header: {
                Text("Shift")
            }

            Section {
                Label {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(viewModel.clash.task.title).bold()
                        Text("Due \(viewModel.clash.task.dueDate.formatted(date: .abbreviated, time: .shortened))")
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: "doc.text.fill")
                        .foregroundStyle(.blue)
                }
            } header: {
                Text("Deadline")
            }

            Section {
                Label("\(viewModel.clash.freeStudyHours, specifier: "%.1f") free study hours before this deadline", systemImage: "clock.fill")
                    .font(.headline)
                    .foregroundStyle(.orange)
            }

            if !viewModel.clash.task.isSubmitted {
                Section {
                    Button {
                        viewModel.markAsSubmitted()
                    } label: {
                        Label("Mark as Submitted", systemImage: "checkmark.circle.fill")
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
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
