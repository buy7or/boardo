import Foundation
import UserNotifications

enum NotificationSchedulerError: Error {
    case permissionDenied
}

struct NotificationScheduler {
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

    func scheduleTestNotification(after seconds: TimeInterval = 10) async throws {
        let content = UNMutableNotificationContent()
        content.title = "Boardo"
        content.body = "Esta es una notificacion de prueba."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let request = UNNotificationRequest(
            identifier: "boardo.test.notification",
            content: content,
            trigger: trigger
        )

        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [request.identifier])
        try await center.add(request)
    }
}
