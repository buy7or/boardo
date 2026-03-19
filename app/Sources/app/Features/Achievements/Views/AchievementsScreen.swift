import SwiftUI

struct AchievementsScreen: View {
    @Bindable var viewModel: BoardViewModel
    @AppStorage(L10n.languagePreferenceKey) private var selectedLanguageCode = L10n.defaultSupportedLanguageCode()

    var body: some View {
        BoardSurface {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    header
                    ForEach(Array(achievementItems.enumerated()), id: \.element.id) { index, item in
                        achievementCard(item: item, index: index)
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
            Text(tr("achievements.title"))
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(AppTheme.Colors.title)
            Text(tr("achievements.subtitle"))
                .font(.subheadline)
                .foregroundStyle(AppTheme.Colors.subtitle)
        }
    }

    private func achievementCard(item: AchievementItem, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.72))
                        .frame(width: 52, height: 52)
                    Image(systemName: item.symbol)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(item.isUnlocked ? AppTheme.Colors.accent : AppTheme.Colors.subtitle)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(AppTheme.Colors.title)
                        .lineLimit(1)
                    Text(item.description)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(AppTheme.Colors.subtitle)
                        .lineLimit(2)
                }

                Spacer(minLength: 0)

                Image(systemName: item.isUnlocked ? "sparkles" : "lock.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(item.isUnlocked ? AppTheme.Colors.accent : AppTheme.Colors.subtitle.opacity(0.85))
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(String(format: tr("achievements.progress"), item.current, item.target))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppTheme.Colors.title.opacity(0.75))
                    Spacer()
                    Text("\(Int((item.progress * 100).rounded()))%")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(AppTheme.Colors.title.opacity(0.6))
                }

                GeometryReader { proxy in
                    let width = proxy.size.width
                    ZStack(alignment: .leading) {
                        Capsule(style: .continuous)
                            .fill(Color.white.opacity(0.45))
                        Capsule(style: .continuous)
                            .fill(item.isUnlocked ? AppTheme.Colors.accent : AppTheme.Colors.subtitle.opacity(0.5))
                            .frame(width: max(8, width * item.progress))
                    }
                }
                .frame(height: 9)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [item.color, item.color.opacity(0.82)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.white.opacity(0.4))
                .frame(width: 64, height: 12)
                .offset(y: -6)
        }
        .overlay {
            RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous)
                .stroke(Color.white.opacity(0.4), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous))
        .rotationEffect(.degrees(index.isMultiple(of: 2) ? -0.8 : 0.8))
        .shadow(color: AppTheme.Shadow.card, radius: 10, x: 0, y: 5)
    }

    private var achievementItems: [AchievementItem] {
        let metrics = Dictionary(uniqueKeysWithValues: viewModel.achievementMetrics().map { ($0.id, $0) })
        func metric(for id: AchievementID) -> AchievementMetric {
            metrics[id] ?? AchievementMetric(id: id, current: 0, target: 1)
        }

        return [
            AchievementItem(
                id: .firstStep,
                title: tr("achievements.firstStep.title"),
                description: tr("achievements.firstStep.description"),
                current: metric(for: .firstStep).current,
                target: metric(for: .firstStep).target,
                symbol: "star.fill",
                color: AppTheme.Colors.stickyYellow
            ),
            AchievementItem(
                id: .onTrack,
                title: tr("achievements.onTrack.title"),
                description: tr("achievements.onTrack.description"),
                current: metric(for: .onTrack).current,
                target: metric(for: .onTrack).target,
                symbol: "flag.fill",
                color: AppTheme.Colors.stickyBlue
            ),
            AchievementItem(
                id: .consistent,
                title: tr("achievements.consistent.title"),
                description: tr("achievements.consistent.description"),
                current: metric(for: .consistent).current,
                target: metric(for: .consistent).target,
                symbol: "flame.fill",
                color: AppTheme.Colors.stickyMint
            ),
            AchievementItem(
                id: .unstoppable,
                title: tr("achievements.unstoppable.title"),
                description: tr("achievements.unstoppable.description"),
                current: metric(for: .unstoppable).current,
                target: metric(for: .unstoppable).target,
                symbol: "bolt.fill",
                color: AppTheme.Colors.stickyPink
            ),
            AchievementItem(
                id: .solidWeek,
                title: tr("achievements.solidWeek.title"),
                description: tr("achievements.solidWeek.description"),
                current: metric(for: .solidWeek).current,
                target: metric(for: .solidWeek).target,
                symbol: "chart.bar.fill",
                color: AppTheme.Colors.stickyPeach
            ),
            AchievementItem(
                id: .organized,
                title: tr("achievements.organized.title"),
                description: tr("achievements.organized.description"),
                current: metric(for: .organized).current,
                target: metric(for: .organized).target,
                symbol: "tray.full.fill",
                color: AppTheme.Colors.stickyLilac
            ),
            AchievementItem(
                id: .taskMaster,
                title: tr("achievements.taskMaster.title"),
                description: tr("achievements.taskMaster.description"),
                current: metric(for: .taskMaster).current,
                target: metric(for: .taskMaster).target,
                symbol: "checklist.checked",
                color: AppTheme.Colors.stickyMint
            ),
            AchievementItem(
                id: .marathoner,
                title: tr("achievements.marathoner.title"),
                description: tr("achievements.marathoner.description"),
                current: metric(for: .marathoner).current,
                target: metric(for: .marathoner).target,
                symbol: "figure.run",
                color: AppTheme.Colors.stickyPeach
            ),
            AchievementItem(
                id: .momentum,
                title: tr("achievements.momentum.title"),
                description: tr("achievements.momentum.description"),
                current: metric(for: .momentum).current,
                target: metric(for: .momentum).target,
                symbol: "flame.circle.fill",
                color: AppTheme.Colors.stickyBlue
            ),
            AchievementItem(
                id: .legend,
                title: tr("achievements.legend.title"),
                description: tr("achievements.legend.description"),
                current: metric(for: .legend).current,
                target: metric(for: .legend).target,
                symbol: "crown.fill",
                color: AppTheme.Colors.stickyYellow
            ),
            AchievementItem(
                id: .perfectWeek,
                title: tr("achievements.perfectWeek.title"),
                description: tr("achievements.perfectWeek.description"),
                current: metric(for: .perfectWeek).current,
                target: metric(for: .perfectWeek).target,
                symbol: "calendar.badge.checkmark",
                color: AppTheme.Colors.stickyPink
            ),
            AchievementItem(
                id: .dailyFocus,
                title: tr("achievements.dailyFocus.title"),
                description: tr("achievements.dailyFocus.description"),
                current: metric(for: .dailyFocus).current,
                target: metric(for: .dailyFocus).target,
                symbol: "sun.max.fill",
                color: AppTheme.Colors.stickyLilac
            ),
        ]
    }

    private func tr(_ key: String) -> String {
        L10n.tr(key, languageCode: selectedLanguageCode)
    }
}

private struct AchievementItem: Identifiable {
    let id: AchievementID
    let title: String
    let description: String
    let current: Int
    let target: Int
    let symbol: String
    let color: Color

    var isUnlocked: Bool {
        current >= target
    }

    var progress: CGFloat {
        guard target > 0 else { return 0 }
        let ratio = CGFloat(current) / CGFloat(target)
        return min(max(ratio, 0), 1)
    }
}
