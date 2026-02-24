import Foundation

struct BoardTasksStore {
    private let defaults: UserDefaults
    private let key = "board_tasks_v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadTasks() -> [BoardTask]? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode([BoardTask].self, from: data)
    }

    func saveTasks(_ tasks: [BoardTask]) {
        guard let data = try? JSONEncoder().encode(tasks) else { return }
        defaults.set(data, forKey: key)
    }
}
