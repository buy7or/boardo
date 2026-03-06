import SwiftUI

struct StatsScreen: View {
    @Bindable var viewModel: BoardViewModel

    var body: some View {
        BoardSurface {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    header
                    metricCard(
                        title: L10n.tr("stats.currentStreak"),
                        value: String(format: L10n.tr("stats.daysValue"), currentStreak),
                        color: AppTheme.Colors.stickyYellow,
                        icon: "flame"
                    )
                    metricCard(
                        title: L10n.tr("stats.longestStreak"),
                        value: String(format: L10n.tr("stats.daysValue"), longestStreak),
                        color: AppTheme.Colors.stickyPink,
                        icon: "flame.fill"
                    )
                    metricCard(
                        title: L10n.tr("stats.completedTasks"),
                        value: "\(completedTasksCount)",
                        color: AppTheme.Colors.stickyMint,
                        icon: "checkmark.circle"
                    )
                    metricCard(
                        title: L10n.tr("stats.completionRate"),
                        value: completionRateText,
                        color: AppTheme.Colors.stickyBlue,
                        icon: "chart.pie"
                    )
                    metricCard(
                        title: L10n.tr("stats.bestDay"),
                        value: bestDayText,
                        color: AppTheme.Colors.stickyYellow.opacity(0.9),
                        icon: "calendar"
                    )
                    metricCard(
                        title: L10n.tr("stats.bestWeek"),
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
            Text(L10n.tr("stats.title"))
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(AppTheme.Colors.title)
            Text(L10n.tr("stats.subtitle"))
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
            return String(format: L10n.tr("stats.percentWithCount"), 0, 0, 0)
        }

        let percent = Int((Double(completedTasksCount) / Double(viewModel.tasks.count) * 100).rounded())
        return String(format: L10n.tr("stats.percentWithCount"), percent, completedTasksCount, viewModel.tasks.count)
    }

    private var currentStreak: Int {
        streakValues.current
    }

    private var longestStreak: Int {
        streakValues.longest
    }

    private var streakValues: (current: Int, longest: Int) {
        let calendar = Calendar.current
        let completedDays = Set(
            viewModel.tasks.compactMap { task -> Date? in
                guard task.isCompleted, let dueDate = task.dueDate else { return nil }
                return calendar.startOfDay(for: dueDate)
            }
        )
        guard !completedDays.isEmpty else { return (0, 0) }

        let sortedDays = completedDays.sorted()
        var longest = 1
        var running = 1

        for index in 1..<sortedDays.count {
            let previous = sortedDays[index - 1]
            let current = sortedDays[index]
            if let expected = calendar.date(byAdding: .day, value: 1, to: previous),
               calendar.isDate(expected, inSameDayAs: current) {
                running += 1
            } else {
                running = 1
            }
            longest = max(longest, running)
        }

        var current = 0
        var day = calendar.startOfDay(for: Date())
        while completedDays.contains(day) {
            current += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = previous
        }

        return (current, longest)
    }

    private var bestDayText: String {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: viewModel.tasks.filter { $0.isCompleted && $0.dueDate != nil }) { task in
            calendar.startOfDay(for: task.dueDate!)
        }

        guard let best = grouped.max(by: { lhs, rhs in lhs.value.count < rhs.value.count }) else {
            return L10n.tr("stats.noData")
        }

        let formatter = DateFormatter()
        formatter.locale = L10n.currentLocale()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return String(format: L10n.tr("stats.bestDateWithCount"), formatter.string(from: best.key), best.value.count)
    }

    private var bestWeekText: String {
        let calendar = Calendar.current
        let tasks = viewModel.tasks.filter { $0.isCompleted && $0.dueDate != nil }
        guard !tasks.isEmpty else { return L10n.tr("stats.noData") }

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
            return L10n.tr("stats.noData")
        }

        var weekComponents = DateComponents()
        weekComponents.weekOfYear = best.key.weekOfYear
        weekComponents.yearForWeekOfYear = best.key.yearForWeekOfYear
        weekComponents.weekday = calendar.firstWeekday

        guard let weekStart = calendar.date(from: weekComponents),
              let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) else {
            return L10n.tr("stats.noData")
        }

        let formatter = DateIntervalFormatter()
        formatter.locale = L10n.currentLocale()
        formatter.dateStyle = .short
        formatter.timeStyle = .none

        let range = formatter.string(from: weekStart, to: weekEnd)
        return String(format: L10n.tr("stats.bestWeekWithCount"), range, best.value.count)
    }
}
