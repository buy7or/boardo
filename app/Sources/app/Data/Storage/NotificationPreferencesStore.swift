import Foundation

struct NotificationPreferences: Codable {
    let isEnabled: Bool
    let hour: Int
    let minute: Int
}

struct NotificationPreferencesStore {
    private let defaults: UserDefaults
    private let key = "board_notification_preferences_v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadPreferences() -> NotificationPreferences? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(NotificationPreferences.self, from: data)
    }

    func savePreferences(_ preferences: NotificationPreferences) {
        guard let data = try? JSONEncoder().encode(preferences) else { return }
        defaults.set(data, forKey: key)
    }
}
