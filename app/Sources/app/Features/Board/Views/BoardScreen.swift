import SwiftUI

struct BoardScreen: View {
    @Bindable var viewModel: BoardViewModel
    var showsBottomNavigation: Bool = true
    var onBottomNavigationVisibilityChange: (Bool) -> Void = { _ in }
    var onPagingLockChange: (Bool) -> Void = { _ in }
    @State private var showAddTaskSheet = false
    @State private var showLargeCalendar = false
    @State private var expandedTaskID: UUID?
    private let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]

    var body: some View {
        BoardSurface {
            VStack(spacing: 12) {
                CompactMonthCalendar(
                    selectedDate: $viewModel.selectedDate,
                    taskDates: taskDatesWithEntries,
                    onMonthTitleTap: {
                        showLargeCalendar = true
                    }
                )

                weeklyProgressCard

                ScrollView {
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(Array(viewModel.boardTasks.enumerated()), id: \.element.id) { index, task in
                            StickyTaskCard(task: task, angle: rotation(for: index)) {
                                if !task.isCompleted {
                                    CompletionFeedbackPlayer.play()
                                }
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                    viewModel.toggleCompletion(taskID: task.id)
                                }
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
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                            viewModel.toggleCompletion(taskID: task.id)
                        }
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

    private var weeklyProgressCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(L10n.tr("board.weeklyProgress.title"))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.Colors.title)

                Spacer()

                Text("\(weeklyCompletedCount)/\(weeklyTasks.count)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppTheme.Colors.accent)
            }

            ProgressView(value: weeklyProgress)
                .tint(AppTheme.Colors.accent)

            Text(
                String(
                    format: L10n.tr("board.weeklyProgress.detail"),
                    weeklyProgressPercent
                )
            )
            .font(.caption)
            .foregroundStyle(AppTheme.Colors.subtitle)
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous))
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

    private func notifyScreenState() {
        let hasPresentedOverlay = showAddTaskSheet || expandedTaskID != nil || showLargeCalendar
        onBottomNavigationVisibilityChange(hasPresentedOverlay)
        onPagingLockChange(hasPresentedOverlay)
    }
}
