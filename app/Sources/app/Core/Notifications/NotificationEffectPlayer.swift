import AudioToolbox
import Foundation
import UIKit

enum NotificationEffectPlayer {
    @MainActor
    static func playArrivalFeedback() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

extension Notification.Name {
    static let boardoDidReceiveNotification = Notification.Name("boardo.didReceiveNotification")
}
