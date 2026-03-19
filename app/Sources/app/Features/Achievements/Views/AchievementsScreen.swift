import SwiftUI

struct AchievementsScreen: View {
    @Bindable var viewModel: BoardViewModel

    var body: some View {
        BoardSurface {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    header
                    ForEach(achievementItems) { item in
                        achievementCard(item: item)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 110)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(L10n.tr("achievements.title"))
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(AppTheme.Colors.title)
            Text(L10n.tr("achievements.subtitle"))
                .font(.subheadline)
                .foregroundStyle(AppTheme.Colors.subtitle)
        }
    }

    private func achievementCard(item: AchievementItem) -> some View {
        HStack(spacing: 12) {
            Image(systemName: item.isUnlocked ? "rosette" : "rosette")
                .font(.headline.weight(.semibold))
                .foregroundStyle(item.isUnlocked ? AppTheme.Colors.accent : AppTheme.Colors.subtitle)
                .frame(width: 30, height: 30)
                .background(Color.white.opacity(0.5))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.Colors.subtitle)
                Text(item.description)
                    .font(AppTheme.Typography.stickyCardBody)
                    .foregroundStyle(AppTheme.Colors.title.opacity(0.9))
                    .lineLimit(2)
                Text(String(format: L10n.tr("achievements.progress"), item.current, item.target))
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(AppTheme.Colors.title.opacity(0.7))
            }
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(item.color)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.white.opacity(0.32))
                .frame(width: 50, height: 12)
                .offset(y: -6)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sticky, style: .continuous))
        .shadow(color: AppTheme.Shadow.card, radius: 8, x: 0, y: 4)
    }

    private var completedTasksCount: Int {
        viewModel.tasks.filter(\.isCompleted).count
    }

    private var weeklyCompletionPercent: Int {
        let calendar = Calendar.current
        let weekTasks = viewModel.tasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            let left = calendar.dateComponents([.weekOfYear, .yearForWeekOfYear], from: dueDate)
            let right = calendar.dateComponents([.weekOfYear, .yearForWeekOfYear], from: viewModel.selectedDate)
            return left.weekOfYear == right.weekOfYear && left.yearForWeekOfYear == right.yearForWeekOfYear
        }
        guard !weekTasks.isEmpty else { return 0 }
        let ratio = Double(weekTasks.filter(\.isCompleted).count) / Double(weekTasks.count)
        return Int((ratio * 100).rounded())
    }

    private var achievementItems: [AchievementItem] {
        [
            AchievementItem(
                title: L10n.tr("achievements.firstStep.title"),
                description: L10n.tr("achievements.firstStep.description"),
                current: min(completedTasksCount, 1),
                target: 1,
                color: AppTheme.Colors.stickyYellow
            ),
            AchievementItem(
                title: L10n.tr("achievements.onTrack.title"),
                description: L10n.tr("achievements.onTrack.description"),
                current: min(completedTasksCount, 10),
                target: 10,
                color: AppTheme.Colors.stickyBlue
            ),
            AchievementItem(
                title: L10n.tr("achievements.consistent.title"),
                description: L10n.tr("achievements.consistent.description"),
                current: min(viewModel.currentStreak(), 3),
                target: 3,
                color: AppTheme.Colors.stickyMint
            ),
            AchievementItem(
                title: L10n.tr("achievements.unstoppable.title"),
                description: L10n.tr("achievements.unstoppable.description"),
                current: min(viewModel.currentStreak(), 7),
                target: 7,
                color: AppTheme.Colors.stickyPink
            ),
            AchievementItem(
                title: L10n.tr("achievements.solidWeek.title"),
                description: L10n.tr("achievements.solidWeek.description"),
                current: min(weeklyCompletionPercent, 80),
                target: 80,
                color: AppTheme.Colors.stickyPeach
            ),
            AchievementItem(
                title: L10n.tr("achievements.organized.title"),
                description: L10n.tr("achievements.organized.description"),
                current: min(viewModel.tasks.count, 25),
                target: 25,
                color: AppTheme.Colors.stickyLilac
            ),
        ]
    }
}

private struct AchievementItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let current: Int
    let target: Int
    let color: Color

    var isUnlocked: Bool {
        current >= target
    }
}
