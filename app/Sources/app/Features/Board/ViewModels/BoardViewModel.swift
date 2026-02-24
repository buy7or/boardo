import Foundation
import Observation

@Observable
final class BoardViewModel {
    var selectedDate: Date = Date()
    var tasks: [BoardTask]
    private let store: BoardTasksStore

    init(tasks: [BoardTask]? = nil, store: BoardTasksStore = BoardTasksStore()) {
        self.store = store
        if let tasks {
            self.tasks = tasks
        } else {
            self.tasks = store.loadTasks() ?? BoardMockData.sampleTasks()
        }
    }

    var monthTitle: String {
        selectedDate.boardMonthYearTitle
    }

    var tasksForSelectedDay: [BoardTask] {
        tasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            return dueDate.isSameDay(as: selectedDate)
        }
    }

    var boardTasks: [BoardTask] {
        tasksForSelectedDay
    }

    var inboxTasks: [BoardTask] {
        tasks.filter { $0.dueDate == nil }
    }

    func toggleCompletion(taskID: UUID) {
        guard let index = tasks.firstIndex(where: { $0.id == taskID }) else { return }
        tasks[index].isCompleted.toggle()
        persist()
    }

    func task(id: UUID) -> BoardTask? {
        tasks.first(where: { $0.id == id })
    }

    func updateTask(taskID: UUID, title: String, notes: String, category: TaskCategory) {
        guard let index = tasks.firstIndex(where: { $0.id == taskID }) else { return }
        tasks[index].title = title
        tasks[index].notes = notes
        tasks[index].category = category
        persist()
    }

    func deleteTask(taskID: UUID) {
        tasks.removeAll(where: { $0.id == taskID })
        persist()
    }

    func moveTask(_ taskID: UUID, to date: Date?) {
        guard let index = tasks.firstIndex(where: { $0.id == taskID }) else { return }
        tasks[index].dueDate = date
        persist()
    }

    func addTask(title: String, notes: String, category: TaskCategory, dueDate: Date?) {
        let newTask = BoardTask(title: title, notes: notes, category: category, dueDate: dueDate)
        tasks.insert(newTask, at: 0)
        persist()
    }

    private func persist() {
        store.saveTasks(tasks)
    }
}
