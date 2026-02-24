import SwiftUI

struct CompactMonthCalendar: View {
    @Binding var selectedDate: Date

    private let weekdays = ["S", "M", "T", "W", "T", "F", "S"]

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Image(systemName: "chevron.left")
                Spacer()
                Text(selectedDate.boardMonthYearTitle)
                    .font(.headline)
                Spacer()
                Image(systemName: "chevron.right")
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
                ForEach(1..<8) { offset in
                    let date = Calendar.current.date(byAdding: .day, value: offset - 4, to: selectedDate) ?? selectedDate
                    dayCell(date: date)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous))
        .shadow(color: AppTheme.Shadow.card, radius: 10, x: 0, y: 6)
    }

    private func dayCell(date: Date) -> some View {
        let dayNumber = Calendar.current.component(.day, from: date)
        let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)

        return Button {
            selectedDate = date
        } label: {
            Text("\(dayNumber)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(isSelected ? Color.white : AppTheme.Colors.title)
                .frame(width: 28, height: 28)
                .background(isSelected ? AppTheme.Colors.accent : Color.clear)
                .clipShape(Circle())
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}
