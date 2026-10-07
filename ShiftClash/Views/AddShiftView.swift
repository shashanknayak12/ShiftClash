//
//  AddShiftView.swift
//  ShiftClash
//
//  Created by Shashank Nayak on 7/10/2026.
//

import SwiftUI

struct AddShiftView: View {
    @StateObject private var viewModel: AddShiftViewModel
    @Environment(\.dismiss) private var dismiss
    var onSaved: (() -> Void)?

    init(repository: ScheduleRepository, editing shift: RosteredShift? = nil, initialNote: String = "", onSaved: (() -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: AddShiftViewModel(repository: repository, editing: shift, initialNote: initialNote))
        self.onSaved = onSaved
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Shift Details") {
                    TextField("Workplace", text: $viewModel.workplace)
                    DatePicker("Starts", selection: $viewModel.startsAt)
                    DatePicker("Ends", selection: $viewModel.endsAt)
                    TextField("Note", text: $viewModel.note)
                }
            }
            .navigationTitle(viewModel.isEditing ? "Edit Shift" : "Add Shift")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if viewModel.save() {
                            onSaved?()
                            dismiss()
                        }
                    }
                    .fontWeight(.semibold)
                }
            }
            .alert("Could not save this shift", isPresented: .constant(viewModel.errorMessage != nil), actions: {
                Button("OK") { viewModel.errorMessage = nil }
            }, message: {
                Text(viewModel.errorMessage ?? "")
            })
        }
    }
}
