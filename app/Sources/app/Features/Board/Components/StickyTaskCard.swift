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
                .strikethrough(task.isCompleted, color: AppTheme.Colors.accent)
                .animation(.easeInOut(duration: 0.18), value: task.isCompleted)

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
        .background {
            RoundedRectangle(cornerRadius: AppTheme.Radius.sticky, style: .continuous)
                .fill(task.category.color)
                .overlay {
                    // Subtle paper grain made from soft noise points.
                    ZStack {
                        ForEach(0..<16, id: \.self) { index in
                            Circle()
                                .fill(Color.white.opacity(0.08))
                                .frame(width: CGFloat(2 + (index % 3)), height: CGFloat(2 + (index % 3)))
                                .offset(
                                    x: CGFloat((index * 19) % 110) - 55,
                                    y: CGFloat((index * 13) % 108) - 54
                                )
                        }
                    }
                }
                .overlay {
                    LinearGradient(
                        colors: [Color.white.opacity(0.26), Color.clear, Color.black.opacity(0.07)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
                .overlay(alignment: .topTrailing) {
                    foldCorner
                }
        }
        .overlay(alignment: .top) {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(Color.white.opacity(0.5))
                .frame(width: 48, height: 11)
                .overlay {
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .stroke(Color.white.opacity(0.55), lineWidth: 0.8)
                }
                .offset(y: -5)
                .rotationEffect(.degrees(-3.5))
        }
        .overlay(alignment: .bottomTrailing) {
            Circle()
                .fill(Color.black.opacity(0.06))
                .frame(width: 24, height: 24)
                .blur(radius: 1)
                .offset(x: 12, y: 12)
        }
        .overlay {
            RoundedRectangle(cornerRadius: AppTheme.Radius.sticky, style: .continuous)
                .strokeBorder(Color.black.opacity(0.08), lineWidth: 0.8)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sticky, style: .continuous))
        .rotationEffect(.degrees(angle))
        .shadow(color: Color.black.opacity(0.12), radius: 11, x: 0, y: 7)
        .opacity(task.isCompleted ? 0.82 : 1)
        .contentShape(RoundedRectangle(cornerRadius: AppTheme.Radius.sticky, style: .continuous))
        .onTapGesture(perform: onOpen)
    }

    private var foldCorner: some View {
        ZStack {
            Triangle()
                .fill(Color.white.opacity(0.3))
                .frame(width: 26, height: 26)

            Triangle()
                .stroke(Color.black.opacity(0.06), lineWidth: 0.8)
                .frame(width: 26, height: 26)
        }
        .rotationEffect(.degrees(45))
        .offset(x: 10, y: -9)
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
