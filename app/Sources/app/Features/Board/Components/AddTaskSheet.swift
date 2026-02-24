import SwiftUI

struct AddTaskSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var notes: String = ""
    @State private var selectedCategory: TaskCategory = .personal
    @State private var assignToSelectedDate: Bool = true

    let selectedDate: Date
    let onSave: (String, String, TaskCategory, Date?) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Nueva tarea") {
                    TextField("Titulo", text: $title)
                    TextField("Notas", text: $notes, axis: .vertical)
                        .lineLimit(3)
                }

                Section("Categoria") {
                    Picker("Categoria", selection: $selectedCategory) {
                        ForEach(TaskCategory.allCases) { category in
                            Text(category.label).tag(category)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Fecha") {
                    Toggle("Asignar al dia seleccionado", isOn: $assignToSelectedDate)
                }
            }
            .navigationTitle("New Memory")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        onSave(title, notes, selectedCategory, assignToSelectedDate ? selectedDate : nil)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
