import AudioToolbox
import Foundation

#if canImport(UIKit)
import UIKit
#endif

enum NotificationEffectPlayer {
    @MainActor
    static func playArrivalFeedback() {
        #if canImport(UIKit)
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
    }
}

extension Notification.Name {
    static let boardoDidReceiveNotification = Notification.Name("boardo.didReceiveNotification")
}
