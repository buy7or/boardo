import Foundation

struct BoardCategoriesStore {
    private let defaults: UserDefaults
    private let key = "board_categories_v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadCategories() -> [TaskCategory]? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode([TaskCategory].self, from: data)
    }

    func saveCategories(_ categories: [TaskCategory]) {
        guard let data = try? JSONEncoder().encode(categories) else { return }
        defaults.set(data, forKey: key)
    }
}
