import SwiftUI

struct CompactMonthCalendar: View {
    @Binding var selectedDate: Date
    let taskDates: Set<Date>
    let weeklyCompletedCount: Int
    let weeklyTotalCount: Int
    let weeklyProgress: Double
    let weeklyProgressPercent: Int
    let onMonthTitleTap: () -> Void

    private let weekdays = ["S", "M", "T", "W", "T", "F", "S"]
    private let calendar = Calendar.current

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Button {
                    moveWeek(by: -7)
                } label: {
                    Image(systemName: "chevron.left")
                }
                .buttonStyle(.plain)
                Spacer()
                Button(action: onMonthTitleTap) {
                    HStack(spacing: 6) {
                        Text(selectedDate.boardMonthYearTitle)
                            .font(.headline)
                        Image(systemName: "chevron.down")
                            .font(.caption.weight(.bold))
                    }
                }
                .buttonStyle(.plain)
                Spacer()
                Button {
                    moveWeek(by: 7)
                } label: {
                    Image(systemName: "chevron.right")
                }
                .buttonStyle(.plain)
            }
            .foregroundStyle(AppTheme.Colors.subtitle)

            HStack {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.caption2)
                        .foregroundStyle(AppTheme.Colors.subtitle)
                        .frame(maxWidth: .infinity)
                }
            }

            HStack {
                ForEach(0..<7, id: \.self) { offset in
                    let date = calendar.date(byAdding: .day, value: offset, to: weekStartDate) ?? selectedDate
                    dayCell(date: date)
                }
            }

            Divider()
                .overlay(AppTheme.Colors.subtitle.opacity(0.18))

            HStack(alignment: .center, spacing: 10) {
                Text(L10n.tr("board.weeklyProgress.title"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.Colors.subtitle)

                ProgressView(value: weeklyProgress)
                    .tint(AppTheme.Colors.accent)

                Text("\(weeklyCompletedCount)/\(weeklyTotalCount)")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(AppTheme.Colors.accent)
            }

            Text(
                String(
                    format: L10n.tr("board.weeklyProgress.detail"),
                    weeklyProgressPercent
                )
            )
            .font(.caption2)
            .foregroundStyle(AppTheme.Colors.subtitle)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous))
        .shadow(color: AppTheme.Shadow.card, radius: 10, x: 0, y: 6)
    }

    private func dayCell(date: Date) -> some View {
        let dayNumber = calendar.component(.day, from: date)
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let hasTask = taskDates.contains(calendar.startOfDay(for: date))

        return Button {
            selectedDate = date
        } label: {
            VStack(spacing: 4) {
                Text("\(dayNumber)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(isSelected ? Color.white : AppTheme.Colors.title)
                    .frame(width: 28, height: 28)
                    .background(isSelected ? AppTheme.Colors.accent : Color.clear)
                    .clipShape(Circle())

                Circle()
                    .fill(AppTheme.Colors.accent)
                    .frame(width: 5, height: 5)
                    .opacity(hasTask ? 1 : 0)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    private var weekStartDate: Date {
        calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start ?? selectedDate
    }

    private func moveWeek(by days: Int) {
        guard let newDate = calendar.date(byAdding: .day, value: days, to: selectedDate) else { return }
        withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
            selectedDate = newDate
        }
    }
}
