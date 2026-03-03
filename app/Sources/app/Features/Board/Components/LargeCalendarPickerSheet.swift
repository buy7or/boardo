import SwiftUI

struct LargeCalendarPickerSheet: View {
    @Binding var selectedDate: Date
    let tasks: [BoardTask]
    let onClose: () -> Void

    @State private var displayMonth: Date
    private let calendar = Calendar.current
    private let weekdays = ["S", "M", "T", "W", "T", "F", "S"]

    init(selectedDate: Binding<Date>, tasks: [BoardTask], onClose: @escaping () -> Void) {
        _selectedDate = selectedDate
        self.tasks = tasks
        self.onClose = onClose
        _displayMonth = State(initialValue: Self.monthStart(for: selectedDate.wrappedValue))
    }

    var body: some View {
        VStack(spacing: 14) {
            capsuleDecor
            monthHeader
            weekdaysHeader
            monthGrid
        }
        .padding(16)
        .frame(maxWidth: 360)
        .background(AppTheme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.large, style: .continuous))
        .shadow(color: AppTheme.Shadow.card, radius: 18, x: 0, y: 12)
        .highPriorityGesture(
            DragGesture(minimumDistance: 24)
                .onEnded { value in
                    handleMonthSwipe(translation: value.translation)
                }
        )
    }

    private var capsuleDecor: some View {
        HStack {
            HStack(spacing: 8) {
                ForEach(0..<4, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(Color.gray.opacity(0.25))
                        .frame(width: 8, height: 18)
                }
            }

            Spacer()

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(AppTheme.Colors.subtitle)
                    .frame(width: 28, height: 28)
                    .background(Color.white.opacity(0.75))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
    }

    private var monthHeader: some View {
        HStack {
            Button {
                moveMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.headline.weight(.bold))
            }
            .buttonStyle(.plain)

            Spacer()

            Text(displayMonth.boardMonthYearTitle)
                .font(AppTheme.Typography.stickyBody)
                .foregroundStyle(AppTheme.Colors.title)

            Spacer()

            Button {
                moveMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.headline.weight(.bold))
            }
            .buttonStyle(.plain)
        }
        .foregroundStyle(AppTheme.Colors.subtitle)
    }

    private var weekdaysHeader: some View {
        HStack {
            ForEach(weekdays, id: \.self) { day in
                Text(day)
                    .font(AppTheme.Typography.stickyTag)
                    .foregroundStyle(AppTheme.Colors.subtitle.opacity(0.8))
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, 8)
    }

    private var monthGrid: some View {
        let cells = monthCells

        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 12) {
            ForEach(cells.indices, id: \.self) { index in
                if let date = cells[index] {
                    dayCell(for: date)
                } else {
                    Color.clear
                        .frame(height: 36)
                }
            }
        }
    }

    private func dayCell(for date: Date) -> some View {
        let day = calendar.component(.day, from: date)
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let hasTask = hasTaskOnDate(calendar.startOfDay(for: date))

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                selectedDate = date
            }
        } label: {
            VStack(spacing: 4) {
                Text("\(day)")
                    .font(AppTheme.Typography.stickyCardBody)
                    .foregroundStyle(isSelected ? .white : AppTheme.Colors.title)
                    .frame(width: 34, height: 34)
                    .background(isSelected ? AppTheme.Colors.accent : Color.clear)
                    .clipShape(Circle())

                Circle()
                    .fill(AppTheme.Colors.accent)
                    .frame(width: 6, height: 6)
                    .opacity(hasTask ? 1 : 0)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    private var monthCells: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayMonth) else { return [] }
        let firstDay = monthInterval.start
        let daysCount = calendar.range(of: .day, in: .month, for: firstDay)?.count ?? 0

        let weekday = calendar.component(.weekday, from: firstDay)
        let leadingBlanks = max(0, weekday - 1)

        var cells: [Date?] = Array(repeating: nil, count: leadingBlanks)
        for dayOffset in 0..<daysCount {
            let date = calendar.date(byAdding: .day, value: dayOffset, to: firstDay)
            cells.append(date)
        }
        return cells
    }

    private func hasTaskOnDate(_ date: Date) -> Bool {
        tasks.contains {
            guard let dueDate = $0.dueDate else { return false }
            return calendar.isDate(dueDate, inSameDayAs: date)
        }
    }

    private func moveMonth(by value: Int) {
        guard let next = calendar.date(byAdding: .month, value: value, to: displayMonth) else { return }
        withAnimation(.spring(response: 0.34, dampingFraction: 0.84)) {
            displayMonth = Self.monthStart(for: next)
        }
    }

    private func handleMonthSwipe(translation: CGSize) {
        let horizontal = translation.width
        let vertical = translation.height
        guard abs(horizontal) > abs(vertical), abs(horizontal) > 40 else { return }
        moveMonth(by: horizontal < 0 ? 1 : -1)
    }

    private static func monthStart(for date: Date) -> Date {
        Calendar.current.dateInterval(of: .month, for: date)?.start ?? date
    }
}
