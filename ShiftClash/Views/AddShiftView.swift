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

    init(repository: ScheduleRepository, initialNote: String = "", onSaved: (() -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: AddShiftViewModel(repository: repository, initialNote: initialNote))
        self.onSaved = onSaved
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Workplace", text: $viewModel.workplace)
                DatePicker("Starts", selection: $viewModel.startsAt)
                DatePicker("Ends", selection: $viewModel.endsAt)
                TextField("Note", text: $viewModel.note)
            }
            .navigationTitle("Add Shift")
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
                }
            }
            .alert("Could not add this shift", isPresented: .constant(viewModel.errorMessage != nil), actions: {
                Button("OK") { viewModel.errorMessage = nil }
            }, message: {
                Text(viewModel.errorMessage ?? "")
            })
        }
    }
}
