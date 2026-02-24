import SwiftUI

struct StickyTaskCard: View {
    let task: BoardTask
    let angle: Double
    let onToggle: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Spacer(minLength: 0)

            Text(task.title)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundStyle(AppTheme.Colors.title)
                .strikethrough(task.isCompleted)
                .lineLimit(3)

            Spacer(minLength: 0)

            HStack {
                Text(task.category.boardTag)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.Colors.subtitle.opacity(0.85))

                Spacer()

                Button(action: onToggle) {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : task.category.icon)
                        .font(.caption)
                        .foregroundStyle(task.isCompleted ? .green : AppTheme.Colors.subtitle.opacity(0.85))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 140, maxHeight: 140, alignment: .leading)
        .background(task.category.color)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sticky, style: .continuous))
        .rotationEffect(.degrees(angle))
        .shadow(color: AppTheme.Shadow.card, radius: 8, x: 0, y: 5)
        .opacity(task.isCompleted ? 0.65 : 1)
    }
}
