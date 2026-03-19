import Foundation
import Observation

@Observable
final class BoardViewModel {
    var selectedDate: Date = Date()
    var tasks: [BoardTask]
    var categories: [TaskCategory]
    private let store: BoardTasksStore
    private let categoriesStore: BoardCategoriesStore

    init(
        tasks: [BoardTask]? = nil,
        store: BoardTasksStore = BoardTasksStore(),
        categoriesStore: BoardCategoriesStore = BoardCategoriesStore()
    ) {
        self.store = store
        self.categoriesStore = categoriesStore
        var loadedCategories = categoriesStore.loadCategories() ?? TaskCategory.defaultCategories

        let initialTasks: [BoardTask]
        if let tasks {
            initialTasks = tasks
        } else {
            initialTasks = store.loadTasks() ?? BoardMockData.sampleTasks()
        }

        var hasCategoryChanges = false
        let normalizedTasks = initialTasks.map { task in
            var mutableTask = task
            mutableTask.category = Self.normalizedCategory(
                for: task.category,
                in: &loadedCategories,
                didChange: &hasCategoryChanges
            )
            return mutableTask
        }
        self.categories = loadedCategories
        self.tasks = normalizedTasks

        if hasCategoryChanges {
            categoriesStore.saveCategories(loadedCategories)
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

    func currentStreak(referenceDate: Date = Date()) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: referenceDate)
        var anchorDay = today

        if !completedDays.contains(today) {
            guard
                let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
                completedDays.contains(yesterday)
            else {
                return 0
            }
            anchorDay = yesterday
        }

        var streak = 0
        var day = anchorDay

        while completedDays.contains(day) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = previousDay
        }

        return streak
    }

    func longestStreak() -> Int {
        let calendar = Calendar.current
        let sortedDays = completedDays.sorted()
        guard !sortedDays.isEmpty else { return 0 }

        var longest = 1
        var running = 1

        for index in 1..<sortedDays.count {
            let previous = sortedDays[index - 1]
            let current = sortedDays[index]
            if let expected = calendar.date(byAdding: .day, value: 1, to: previous),
               calendar.isDate(expected, inSameDayAs: current) {
                running += 1
            } else {
                running = 1
            }
            longest = max(longest, running)
        }

        return longest
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
        var hasCategoryChanges = false
        let normalized = normalizedCategory(for: category, didChange: &hasCategoryChanges)
        tasks[index].title = title
        tasks[index].notes = notes
        tasks[index].category = normalized
        if hasCategoryChanges {
            categoriesStore.saveCategories(categories)
        }
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
        var hasCategoryChanges = false
        let normalized = normalizedCategory(for: category, didChange: &hasCategoryChanges)
        let newTask = BoardTask(title: title, notes: notes, category: normalized, dueDate: dueDate)
        tasks.insert(newTask, at: 0)
        if hasCategoryChanges {
            categoriesStore.saveCategories(categories)
        }
        persist()
    }

    func addCategory(name: String, colorStyle: PostItColorStyle, icon: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        guard !categories.contains(where: { $0.label.caseInsensitiveCompare(trimmedName) == .orderedSame }) else {
            return
        }

        categories.append(TaskCategory(label: trimmedName, icon: icon, colorStyle: colorStyle))
        categoriesStore.saveCategories(categories)
    }

    func deleteCategory(_ category: TaskCategory) {
        guard categories.count > 1 else { return }
        guard categories.contains(where: { $0.id == category.id }) else { return }
        guard let replacement = categories.first(where: { $0.id != category.id }) else { return }

        categories.removeAll(where: { $0.id == category.id })
        for index in tasks.indices where tasks[index].category.id == category.id {
            tasks[index].category = replacement
        }

        categoriesStore.saveCategories(categories)
        persist()
    }

    private func persist() {
        store.saveTasks(tasks)
    }

    private var completedDays: Set<Date> {
        let calendar = Calendar.current
        return Set(
            tasks.compactMap { task in
                guard task.isCompleted, let dueDate = task.dueDate else { return nil }
                return calendar.startOfDay(for: dueDate)
            }
        )
    }

    private func normalizedCategory(for category: TaskCategory, didChange: inout Bool) -> TaskCategory {
        Self.normalizedCategory(for: category, in: &categories, didChange: &didChange)
    }

    private static func normalizedCategory(
        for category: TaskCategory,
        in categories: inout [TaskCategory],
        didChange: inout Bool
    ) -> TaskCategory {
        if let existingByID = categories.first(where: { $0.id == category.id }) {
            return existingByID
        }

        if let existingByName = categories.first(where: { $0.label.caseInsensitiveCompare(category.label) == .orderedSame }) {
            return existingByName
        }

        categories.append(category)
        didChange = true
        return category
    }
}
