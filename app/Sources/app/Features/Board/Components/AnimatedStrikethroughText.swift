import SwiftUI

struct AnimatedStrikethroughText: View {
    let text: String
    let font: Font
    let color: Color
    let lineLimit: Int
    let isCompleted: Bool
    @State private var progress: CGFloat = 0

    var body: some View {
        ZStack(alignment: .leading) {
            Text(text)
                .font(font)
                .foregroundStyle(color)
                .lineLimit(lineLimit)

            GeometryReader { proxy in
                Text(text)
                    .font(font)
                    .foregroundStyle(Color.clear)
                    .lineLimit(lineLimit)
                    .strikethrough(true, color: AppTheme.Colors.accent)
                    .mask(alignment: .leading) {
                        Rectangle()
                            .frame(width: proxy.size.width * progress)
                    }
            }
        }
        .onAppear {
            progress = isCompleted ? 1 : 0
        }
        .onChange(of: isCompleted) { _, newValue in
            withAnimation(.spring(response: 0.34, dampingFraction: 0.8)) {
                progress = newValue ? 1 : 0
            }
        }
    }
}
