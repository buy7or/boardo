import Foundation
import UserNotifications

enum NotificationSchedulerError: Error {
    case permissionDenied
}

struct NotificationScheduler {
    static let dailyNotificationIdentifier = "boardo.daily.notification"

    func requestAuthorizationIfNeeded() async throws {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()

        if settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional {
            return
        }

        if settings.authorizationStatus == .denied {
            throw NotificationSchedulerError.permissionDenied
        }

        let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
        if !granted {
            throw NotificationSchedulerError.permissionDenied
        }
    }

    func scheduleDailyNotification(hour: Int, minute: Int) async throws {
        let content = UNMutableNotificationContent()
        content.title = "Boardo"
        content.body = L10n.tr("notification.daily.body")
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: Self.dailyNotificationIdentifier,
            content: content,
            trigger: trigger
        )

        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [request.identifier])
        try await center.add(request)
    }

    func cancelDailyNotification() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [Self.dailyNotificationIdentifier])
    }
}
