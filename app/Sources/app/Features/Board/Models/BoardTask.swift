import Foundation

struct BoardTask: Identifiable, Equatable {
    let id: UUID
    var title: String
    var notes: String
    var category: TaskCategory
    var dueDate: Date?
    var isCompleted: Bool

    init(
        id: UUID = UUID(),
        title: String,
        notes: String,
        category: TaskCategory,
        dueDate: Date?,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.category = category
        self.dueDate = dueDate
        self.isCompleted = isCompleted
    }
}
