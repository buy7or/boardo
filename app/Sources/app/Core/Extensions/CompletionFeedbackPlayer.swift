import Foundation

#if canImport(UIKit)
import AudioToolbox
import UIKit
#endif

enum CompletionFeedbackPlayer {
    @MainActor
    static func play() {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        // Single short scratch-like sound (closest iOS system sound to pencil mark).
        AudioServicesPlaySystemSound(1104)
        #endif
    }
}
