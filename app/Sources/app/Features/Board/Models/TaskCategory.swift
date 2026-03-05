import SwiftUI

enum PostItColorStyle: String, CaseIterable, Identifiable, Codable {
    case yellow
    case blue
    case pink
    case mint

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .yellow: return AppTheme.Colors.stickyYellow
        case .blue: return AppTheme.Colors.stickyBlue
        case .pink: return AppTheme.Colors.stickyPink
        case .mint: return AppTheme.Colors.stickyMint
        }
    }
}

struct TaskCategory: Identifiable, Equatable, Hashable, Codable {
    let id: String
    var label: String
    var icon: String
    var colorStyle: PostItColorStyle

    var boardTag: String {
        let trimmed = label.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return "TAG" }
        return String(trimmed.uppercased().prefix(10))
    }

    var color: Color {
        colorStyle.color
    }

    init(id: String = UUID().uuidString, label: String, icon: String, colorStyle: PostItColorStyle) {
        self.id = id
        self.label = label
        self.icon = icon
        self.colorStyle = colorStyle
    }
}

extension TaskCategory {
    static let personal = TaskCategory(id: "personal", label: "Personal", icon: "pin.fill", colorStyle: .yellow)
    static let routine = TaskCategory(id: "routine", label: "Rutina", icon: "arrow.triangle.2.circlepath", colorStyle: .blue)
    static let work = TaskCategory(id: "work", label: "Trabajo", icon: "scissors", colorStyle: .mint)
    static let family = TaskCategory(id: "family", label: "Familia", icon: "heart.fill", colorStyle: .pink)
    static let urgent = TaskCategory(id: "urgent", label: "Urgente", icon: "bolt.fill", colorStyle: .mint)

    static var defaultCategories: [TaskCategory] {
        [.personal, .routine, .work, .family, .urgent]
    }

    static func legacyCategory(for rawValue: String) -> TaskCategory {
        switch rawValue {
        case "personal": return .personal
        case "routine": return .routine
        case "work": return .work
        case "family": return .family
        case "urgent": return .urgent
        default:
            return TaskCategory(
                id: rawValue,
                label: rawValue.capitalized,
                icon: "tag.fill",
                colorStyle: .yellow
            )
        }
    }
}

extension TaskCategory {
    private enum CodingKeys: String, CodingKey {
        case id
        case label
        case icon
        case colorStyle
    }

    init(from decoder: Decoder) throws {
        if let legacyValue = try? decoder.singleValueContainer().decode(String.self) {
            self = TaskCategory.legacyCategory(for: legacyValue)
            return
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        let label = try container.decode(String.self, forKey: .label)
        let icon = try container.decodeIfPresent(String.self, forKey: .icon) ?? "tag.fill"
        let colorStyle = try container.decodeIfPresent(PostItColorStyle.self, forKey: .colorStyle) ?? .yellow
        let id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        self.init(id: id, label: label, icon: icon, colorStyle: colorStyle)
    }
}
