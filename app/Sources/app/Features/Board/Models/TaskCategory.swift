import SwiftUI

enum TaskCategory: String, CaseIterable, Identifiable {
    case personal
    case routine
    case work
    case family
    case urgent

    var id: String { rawValue }

    var label: String {
        switch self {
        case .personal: return "Personal"
        case .routine: return "Rutina"
        case .work: return "Trabajo"
        case .family: return "Familia"
        case .urgent: return "Urgente"
        }
    }

    var boardTag: String {
        switch self {
        case .personal: return "TODAY"
        case .routine: return "ROUTINE"
        case .work: return "WORK"
        case .family: return "FAMILY"
        case .urgent: return "URGENT"
        }
    }

    var icon: String {
        switch self {
        case .personal: return "pin.fill"
        case .routine: return "arrow.triangle.2.circlepath"
        case .work: return "scissors"
        case .family: return "heart.fill"
        case .urgent: return "bolt.fill"
        }
    }

    var color: Color {
        switch self {
        case .personal: return AppTheme.Colors.stickyYellow
        case .routine: return AppTheme.Colors.stickyBlue
        case .work: return AppTheme.Colors.stickyMint
        case .family: return AppTheme.Colors.stickyPink
        case .urgent: return AppTheme.Colors.stickyMint
        }
    }
}
