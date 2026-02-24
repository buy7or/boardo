import SwiftUI

enum AppTheme {
    enum Colors {
        static let boardBackground = Color(red: 0.95, green: 0.95, blue: 0.95)
        static let cardBackground = Color(red: 0.98, green: 0.98, blue: 0.98)
        static let accent = Color(red: 0.96, green: 0.42, blue: 0.20)
        static let title = Color(red: 0.15, green: 0.18, blue: 0.24)
        static let subtitle = Color(red: 0.55, green: 0.59, blue: 0.67)

        static let stickyYellow = Color(red: 0.98, green: 0.93, blue: 0.58)
        static let stickyBlue = Color(red: 0.73, green: 0.82, blue: 0.96)
        static let stickyPink = Color(red: 0.95, green: 0.78, blue: 0.88)
        static let stickyMint = Color(red: 0.72, green: 0.90, blue: 0.80)
    }

    enum Radius {
        static let large: CGFloat = 24
        static let medium: CGFloat = 18
        static let sticky: CGFloat = 12
    }

    enum Shadow {
        static let card = Color.black.opacity(0.08)
    }
}
