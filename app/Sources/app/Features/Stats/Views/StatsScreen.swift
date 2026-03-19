import SwiftUI

struct StatsScreen: View {
    @Bindable var viewModel: BoardViewModel
    @AppStorage(L10n.languagePreferenceKey) private var selectedLanguageCode = L10n.defaultSupportedLanguageCode()

    var body: some View {
        BoardSurface {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    header
                    metricCard(
                        title: tr("stats.currentStreak"),
                        value: String(format: tr("stats.daysValue"), currentStreak),
                        color: AppTheme.Colors.stickyYellow,
                        icon: "flame"
                    )
                    metricCard(
                        title: tr("stats.longestStreak"),
                        value: String(format: tr("stats.daysValue"), longestStreak),
                        color: AppTheme.Colors.stickyPink,
                        icon: "flame.fill"
                    )
                    metricCard(
                        title: tr("stats.completedTasks"),
                        value: "\(completedTasksCount)",
                        color: AppTheme.Colors.stickyMint,
                        icon: "checkmark.circle"
                    )
                    metricCard(
                        title: tr("stats.completionRate"),
                        value: completionRateText,
                        color: AppTheme.Colors.stickyBlue,
                        icon: "chart.pie"
                    )
                    metricCard(
                        title: tr("stats.bestDay"),
                        value: bestDayText,
                        color: AppTheme.Colors.stickyYellow.opacity(0.9),
                        icon: "calendar"
                    )
                    metricCard(
                        title: tr("stats.bestWeek"),
                        value: bestWeekText,
                        color: AppTheme.Colors.stickyPink.opacity(0.88),
                        icon: "calendar.badge.clock"
                    )
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 110)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(tr("stats.title"))
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(AppTheme.Colors.title)
            Text(tr("stats.subtitle"))
                .font(.subheadline)
                .foregroundStyle(AppTheme.Colors.subtitle)
        }
    }

    private func metricCard(title: String, value: String, color: Color, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.headline.weight(.semibold))
                .foregroundStyle(AppTheme.Colors.accent)
                .frame(width: 30, height: 30)
                .background(Color.white.opacity(0.5))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.Colors.subtitle)
                Text(value)
                    .font(AppTheme.Typography.stickyBody)
                    .foregroundStyle(AppTheme.Colors.title.opacity(0.9))
                    .lineLimit(1)
            }
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(color)
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

    private var completionRateText: String {
        guard !viewModel.tasks.isEmpty else {
            return String(format: tr("stats.percentWithCount"), 0, 0, 0)
        }

        let percent = Int((Double(completedTasksCount) / Double(viewModel.tasks.count) * 100).rounded())
        return String(format: tr("stats.percentWithCount"), percent, completedTasksCount, viewModel.tasks.count)
    }

    private var currentStreak: Int {
        viewModel.currentStreak()
    }

    private var longestStreak: Int {
        viewModel.longestStreak()
    }

    private var bestDayText: String {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: viewModel.tasks.filter { $0.isCompleted && $0.dueDate != nil }) { task in
            calendar.startOfDay(for: task.dueDate!)
        }

        guard let best = grouped.max(by: { lhs, rhs in lhs.value.count < rhs.value.count }) else {
            return tr("stats.noData")
        }

        let formatter = DateFormatter()
        formatter.locale = L10n.currentLocale(languageCode: selectedLanguageCode)
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return String(format: tr("stats.bestDateWithCount"), formatter.string(from: best.key), best.value.count)
    }

    private var bestWeekText: String {
        let calendar = Calendar.current
        let tasks = viewModel.tasks.filter { $0.isCompleted && $0.dueDate != nil }
        guard !tasks.isEmpty else { return tr("stats.noData") }

        struct WeekKey: Hashable {
            let weekOfYear: Int
            let yearForWeekOfYear: Int
        }

        let grouped = Dictionary(grouping: tasks) { task -> WeekKey in
            let components = calendar.dateComponents([.weekOfYear, .yearForWeekOfYear], from: task.dueDate!)
            return WeekKey(
                weekOfYear: components.weekOfYear ?? 0,
                yearForWeekOfYear: components.yearForWeekOfYear ?? 0
            )
        }

        guard let best = grouped.max(by: { lhs, rhs in lhs.value.count < rhs.value.count }) else {
            return tr("stats.noData")
        }

        var weekComponents = DateComponents()
        weekComponents.weekOfYear = best.key.weekOfYear
        weekComponents.yearForWeekOfYear = best.key.yearForWeekOfYear
        weekComponents.weekday = calendar.firstWeekday

        guard let weekStart = calendar.date(from: weekComponents),
              let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) else {
            return tr("stats.noData")
        }

        let formatter = DateIntervalFormatter()
        formatter.locale = L10n.currentLocale(languageCode: selectedLanguageCode)
        formatter.dateStyle = .short
        formatter.timeStyle = .none

        let range = formatter.string(from: weekStart, to: weekEnd)
        return String(format: tr("stats.bestWeekWithCount"), range, best.value.count)
    }

    private func tr(_ key: String) -> String {
        L10n.tr(key, languageCode: selectedLanguageCode)
    }
}
