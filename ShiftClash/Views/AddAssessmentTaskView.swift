//
//  AddAssessmentTaskView.swift
//  ShiftClash
//
//  Created by Shashank Nayak on 7/10/2026.
//

import SwiftUI

struct AddAssessmentTaskView: View {
    @StateObject private var viewModel: AddAssessmentTaskViewModel
    @Environment(\.dismiss) private var dismiss

    init(repository: ScheduleRepository) {
        _viewModel = StateObject(wrappedValue: AddAssessmentTaskViewModel(repository: repository))
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $viewModel.title)

                Picker("Subject", selection: $viewModel.selectedSubjectID) {
                    ForEach(viewModel.subjects) { subject in
                        Text(subject.name).tag(Optional(subject.id))
                    }
                }

                DatePicker("Due Date", selection: $viewModel.dueDate)

                Stepper("Weight: \(viewModel.weightPercent)%", value: $viewModel.weightPercent, in: 1...100)
            }
            .navigationTitle("Add Assessment Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if viewModel.save() {
                            dismiss()
                        }
                    }
                }
            }
            .onAppear(perform: viewModel.loadSubjects)
            .alert("Could not schedule this task", isPresented: .constant(viewModel.errorMessage != nil), actions: {
                Button("OK") { viewModel.errorMessage = nil }
            }, message: {
                Text(viewModel.errorMessage ?? "")
            })
        }
    }
}
