import SwiftUI

struct BoardScreen: View {
    @Bindable var viewModel: BoardViewModel
    var showsBottomNavigation: Bool = true
    var onBottomNavigationVisibilityChange: (Bool) -> Void = { _ in }
    var onPagingLockChange: (Bool) -> Void = { _ in }
    @State private var showAddTaskSheet = false
    @State private var showLargeCalendar = false
    @State private var expandedTaskID: UUID?
    @State private var unlockedAchievement: AchievementID?
    @State private var isAchievementBadgeAnimating = false
    private let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]

    var body: some View {
        BoardSurface {
            VStack(spacing: 12) {
                CompactMonthCalendar(
                    selectedDate: $viewModel.selectedDate,
                    taskDates: taskDatesWithEntries,
                    weeklyCompletedCount: weeklyCompletedCount,
                    weeklyTotalCount: weeklyTasks.count,
                    weeklyProgress: weeklyProgress,
                    weeklyProgressPercent: weeklyProgressPercent,
                    onMonthTitleTap: {
                        showLargeCalendar = true
                    }
                )

                streakStickyCard

                ScrollView {
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(Array(viewModel.boardTasks.enumerated()), id: \.element.id) { index, task in
                            StickyTaskCard(task: task, angle: rotation(for: index)) {
                                if !task.isCompleted {
                                    CompletionFeedbackPlayer.play()
                                }
                                handleCompletionToggle(taskID: task.id, wasCompleted: task.isCompleted)
                            } onOpen: {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                    expandedTaskID = task.id
                                }
                            }
                        }

                        newNoteCard
                    }
                    .padding(.top, 4)
                    .padding(.bottom, 88)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .overlay(alignment: .bottom) {
                if showsBottomNavigation {
                    BottomNavigationBar(selectedTab: .board) { _ in }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 10)
                }
            }
        }
        .fullScreenCover(isPresented: $showAddTaskSheet) {
            AddTaskSheet(selectedDate: viewModel.selectedDate, categories: viewModel.categories) { title, notes, category, date in
                viewModel.addTask(title: title, notes: notes, category: category, dueDate: date)
            }
        }
        .overlay {
            if showLargeCalendar {
                Color.black.opacity(0.2)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.32, dampingFraction: 0.84)) {
                            showLargeCalendar = false
                        }
                    }
                    .highPriorityGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in }
                            .onEnded { _ in }
                    )
                    .transition(.opacity)

                LargeCalendarPickerSheet(
                    selectedDate: $viewModel.selectedDate,
                    tasks: viewModel.tasks,
                    onClose: {
                        withAnimation(.spring(response: 0.32, dampingFraction: 0.84)) {
                            showLargeCalendar = false
                        }
                    }
                )
                .padding(.horizontal, 20)
                .transition(.scale(scale: 0.9).combined(with: .opacity))
            }
        }
        .overlay {
            if let task = expandedTask {
                Color.black.opacity(0.28)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                            expandedTaskID = nil
                        }
                    }
                    .transition(.opacity)

                ExpandedTaskEditor(
                    task: task,
                    categories: viewModel.categories,
                    onClose: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                            expandedTaskID = nil
                        }
                    },
                    onSave: { title, notes, category in
                        viewModel.updateTask(taskID: task.id, title: title, notes: notes, category: category)
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                            expandedTaskID = nil
                        }
                    },
                    onToggleDone: {
                        if !task.isCompleted {
                            CompletionFeedbackPlayer.play()
                        }
                        handleCompletionToggle(taskID: task.id, wasCompleted: task.isCompleted)
                    },
                    onDelete: {
                        viewModel.deleteTask(taskID: task.id)
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                            expandedTaskID = nil
                        }
                    }
                )
                .padding(.horizontal, 16)
                .transition(.scale(scale: 0.9).combined(with: .opacity))
            }
        }
        .overlay(alignment: .top) {
            if let unlockedAchievement {
                achievementUnlockedOverlay(for: unlockedAchievement)
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.82), value: expandedTaskID)
        .animation(.spring(response: 0.32, dampingFraction: 0.84), value: showLargeCalendar)
        .onAppear {
            notifyScreenState()
        }
        .onChange(of: showAddTaskSheet) { _, _ in
            notifyScreenState()
        }
        .onChange(of: expandedTaskID) { _, _ in
            notifyScreenState()
        }
        .onChange(of: showLargeCalendar) { _, _ in
            notifyScreenState()
        }
    }

    private var newNoteCard: some View {
        Button {
            showAddTaskSheet = true
        } label: {
            VStack(spacing: 10) {
                Image(systemName: "plus")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(AppTheme.Colors.accent)
                    .clipShape(Circle())
                    .shadow(color: AppTheme.Shadow.card, radius: 6, x: 0, y: 4)
                Text(L10n.tr("board.newNote"))
                    .font(AppTheme.Typography.stickyTag)
                    .foregroundStyle(AppTheme.Colors.subtitle)
            }
            .frame(maxWidth: .infinity, minHeight: 140, maxHeight: 140)
            .overlay {
                RoundedRectangle(cornerRadius: AppTheme.Radius.sticky, style: .continuous)
                    .stroke(Color.gray.opacity(0.45), style: StrokeStyle(lineWidth: 1.2, dash: [5]))
            }
        }
        .buttonStyle(.plain)
    }

    private var streakStickyCard: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(AppTheme.Colors.accent.opacity(0.65), style: StrokeStyle(lineWidth: 2, dash: [4, 3]))
                    .frame(width: 38, height: 38)

                Image(systemName: dailyStreakCount > 0 ? "flame.fill" : "flame")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(AppTheme.Colors.accent)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(L10n.tr("board.streak.title"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.Colors.subtitle)

                Text(
                    String(
                        format: L10n.tr("board.streak.days"),
                        dailyStreakCount
                    )
                )
                .font(AppTheme.Typography.stickyBody)
                .foregroundStyle(AppTheme.Colors.title.opacity(0.9))
                .lineLimit(1)

                if shouldShowStreakMotivation {
                    Text(L10n.tr("board.streak.motivation"))
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(AppTheme.Colors.title.opacity(0.85))
                        .lineLimit(1)
                }
            }

            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.Colors.stickyYellow)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.white.opacity(0.35))
                .frame(width: 54, height: 12)
                .offset(y: -6)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sticky, style: .continuous))
        .rotationEffect(.degrees(-1.1))
        .shadow(color: AppTheme.Shadow.card, radius: 8, x: 0, y: 4)
    }

    private func rotation(for index: Int) -> Double {
        index.isMultiple(of: 2) ? -1.4 : 1.1
    }

    private var expandedTask: BoardTask? {
        guard let expandedTaskID else { return nil }
        return viewModel.task(id: expandedTaskID)
    }

    private var taskDatesWithEntries: Set<Date> {
        Set(
            viewModel.tasks.compactMap { task in
                guard let dueDate = task.dueDate else { return nil }
                return Calendar.current.startOfDay(for: dueDate)
            }
        )
    }

    private var weeklyTasks: [BoardTask] {
        viewModel.tasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            return isInSameWeek(dueDate, as: viewModel.selectedDate)
        }
    }

    private var weeklyCompletedCount: Int {
        weeklyTasks.filter(\.isCompleted).count
    }

    private var weeklyProgress: Double {
        guard !weeklyTasks.isEmpty else { return 0 }
        return Double(weeklyCompletedCount) / Double(weeklyTasks.count)
    }

    private var weeklyProgressPercent: Int {
        Int((weeklyProgress * 100).rounded())
    }

    private func isInSameWeek(_ lhs: Date, as rhs: Date) -> Bool {
        let calendar = Calendar.current
        let left = calendar.dateComponents([.weekOfYear, .yearForWeekOfYear], from: lhs)
        let right = calendar.dateComponents([.weekOfYear, .yearForWeekOfYear], from: rhs)
        return left.weekOfYear == right.weekOfYear && left.yearForWeekOfYear == right.yearForWeekOfYear
    }

    private var dailyStreakCount: Int {
        viewModel.currentStreak()
    }

    private var hasCompletedTaskToday: Bool {
        let calendar = Calendar.current
        return viewModel.tasks.contains { task in
            guard task.isCompleted, let dueDate = task.dueDate else { return false }
            return calendar.isDate(dueDate, inSameDayAs: Date())
        }
    }

    private var shouldShowStreakMotivation: Bool {
        dailyStreakCount > 0 && !hasCompletedTaskToday
    }

    private func handleCompletionToggle(taskID: UUID, wasCompleted: Bool) {
        if wasCompleted {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                viewModel.toggleCompletion(taskID: taskID)
            }
            return
        }

        let unlockedBefore = viewModel.unlockedAchievementIDs()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
            viewModel.toggleCompletion(taskID: taskID)
        }
        let unlockedAfter = viewModel.unlockedAchievementIDs()
        let newUnlocks = viewModel.newlyUnlockedAchievementIDs(before: unlockedBefore, after: unlockedAfter)

        guard let firstUnlocked = newUnlocks.first else { return }
        showAchievementCelebration(firstUnlocked)
    }

    private func showAchievementCelebration(_ achievementID: AchievementID) {
        unlockedAchievement = achievementID
        isAchievementBadgeAnimating = false

        withAnimation(.spring(response: 0.56, dampingFraction: 0.72)) {
            isAchievementBadgeAnimating = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.9)) {
                unlockedAchievement = nil
                isAchievementBadgeAnimating = false
            }
        }
    }

    private func achievementUnlockedOverlay(for achievementID: AchievementID) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.78))
                    .frame(width: 60, height: 60)
                Image(systemName: achievementSymbol(for: achievementID))
                    .font(.title2.weight(.bold))
                    .foregroundStyle(AppTheme.Colors.accent)
                    .rotationEffect(.degrees(isAchievementBadgeAnimating ? 360 : 0))
                    .scaleEffect(isAchievementBadgeAnimating ? 1 : 0.28)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(L10n.tr("board.achievement.unlocked"))
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppTheme.Colors.subtitle)
                Text(achievementTitle(for: achievementID))
                    .font(AppTheme.Typography.stickyCardBody)
                    .foregroundStyle(AppTheme.Colors.title)
                    .lineLimit(1)
                Text(L10n.tr("board.achievement.keepGoing"))
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(AppTheme.Colors.title.opacity(0.75))
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(AppTheme.Colors.stickyYellow)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.white.opacity(0.4))
                .frame(width: 64, height: 12)
                .offset(y: -6)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous))
        .shadow(color: AppTheme.Shadow.card, radius: 10, x: 0, y: 6)
        .padding(.horizontal, 22)
        .padding(.top, 10)
        .transition(.move(edge: .top).combined(with: .opacity).combined(with: .scale(scale: 0.86)))
    }

    private func achievementTitle(for id: AchievementID) -> String {
        switch id {
        case .firstStep:
            return L10n.tr("achievements.firstStep.title")
        case .onTrack:
            return L10n.tr("achievements.onTrack.title")
        case .consistent:
            return L10n.tr("achievements.consistent.title")
        case .unstoppable:
            return L10n.tr("achievements.unstoppable.title")
        case .solidWeek:
            return L10n.tr("achievements.solidWeek.title")
        case .organized:
            return L10n.tr("achievements.organized.title")
        }
    }

    private func achievementSymbol(for id: AchievementID) -> String {
        switch id {
        case .firstStep:
            return "star.fill"
        case .onTrack:
            return "flag.fill"
        case .consistent:
            return "flame.fill"
        case .unstoppable:
            return "bolt.fill"
        case .solidWeek:
            return "chart.bar.fill"
        case .organized:
            return "tray.full.fill"
        }
    }

    private func notifyScreenState() {
        let hasPresentedOverlay = showAddTaskSheet || expandedTaskID != nil || showLargeCalendar
        onBottomNavigationVisibilityChange(hasPresentedOverlay)
        onPagingLockChange(hasPresentedOverlay)
    }
}
