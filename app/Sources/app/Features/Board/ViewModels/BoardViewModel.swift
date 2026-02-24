import Foundation
import Observation

@Observable
final class BoardViewModel {
    var selectedDate: Date = Date()
    var tasks: [BoardTask]

    init(tasks: [BoardTask] = BoardMockData.sampleTasks()) {
        self.tasks = tasks
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
        tasksForSelectedDay.filter { !$0.isCompleted }
    }

    var inboxTasks: [BoardTask] {
        tasks.filter { $0.dueDate == nil }
    }

    func toggleCompletion(taskID: UUID) {
        guard let index = tasks.firstIndex(where: { $0.id == taskID }) else { return }
        tasks[index].isCompleted.toggle()
    }

    func moveTask(_ taskID: UUID, to date: Date?) {
        guard let index = tasks.firstIndex(where: { $0.id == taskID }) else { return }
        tasks[index].dueDate = date
    }

    func addTask(title: String, notes: String, category: TaskCategory, dueDate: Date?) {
        let newTask = BoardTask(title: title, notes: notes, category: category, dueDate: dueDate)
        tasks.insert(newTask, at: 0)
    }
}
