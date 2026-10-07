//
//  SubjectsView.swift
//  ShiftClash
//
//  Created by Shashank Nayak on 7/10/2026.
//

import SwiftUI

struct SubjectsView: View {
    @StateObject private var viewModel: SubjectsViewModel
    @State private var showingAddSubject = false
    @State private var newCode = ""
    @State private var newName = ""

    init(repository: ScheduleRepository) {
        _viewModel = StateObject(wrappedValue: SubjectsViewModel(repository: repository))
    }

    var body: some View {
        NavigationStack {
            List {
                if viewModel.subjects.isEmpty {
                    ContentUnavailableView(
                        "No subjects yet.",
                        systemImage: "book",
                        description: Text("Add a subject to start scheduling assessment tasks.")
                    )
                } else {
                    ForEach(viewModel.subjects) { subject in
                        Section(subject.name) {
                            if viewModel.tasks(for: subject).isEmpty {
                                Text("No assessment tasks yet.")
                                    .foregroundStyle(.secondary)
                            } else {
                                ForEach(viewModel.tasks(for: subject)) { task in
                                    VStack(alignment: .leading) {
                                        Text(task.title)
                                        Text("Due \(task.dueDate.formatted(date: .abbreviated, time: .omitted)) · \(task.weightPercent)%")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Subjects")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddSubject = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSubject) {
                NavigationStack {
                    Form {
                        TextField("Subject Code", text: $newCode)
                        TextField("Subject Name", text: $newName)
                    }
                    .navigationTitle("Add Subject")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { showingAddSubject = false }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                viewModel.addSubject(code: newCode, name: newName)
                                newCode = ""
                                newName = ""
                                showingAddSubject = false
                            }
                        }
                    }
                }
            }
            .onAppear(perform: viewModel.load)
        }
    }
}
