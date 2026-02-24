import SwiftUI

struct StickyTaskCard: View {
    let task: BoardTask
    let angle: Double
    let onToggle: () -> Void
    let onOpen: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(task.title)
                .font(AppTheme.Typography.stickyCardBody)
                .foregroundStyle(AppTheme.Colors.title)
                .lineLimit(3)
                .animatedStrike(task.isCompleted)

            Spacer(minLength: 0)

            HStack {
                Text(task.category.boardTag)
                    .font(AppTheme.Typography.stickyCardTag)
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
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.white.opacity(0.4))
                .frame(width: 46, height: 10)
                .offset(y: -5)
        }
        .overlay(alignment: .bottomTrailing) {
            Circle()
                .fill(Color.white.opacity(0.2))
                .frame(width: 26, height: 26)
                .offset(x: 11, y: 11)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sticky, style: .continuous))
        .rotationEffect(.degrees(angle))
        .shadow(color: AppTheme.Shadow.card, radius: 8, x: 0, y: 5)
        .opacity(task.isCompleted ? 0.82 : 1)
        .contentShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sticky, style: .continuous))
        .onTapGesture(perform: onOpen)
    }
}
