import SwiftUI

extension View {
    func animatedStrike(_ isCompleted: Bool, color: Color = AppTheme.Colors.accent) -> some View {
        overlay(alignment: .center) {
            GeometryReader { proxy in
                Capsule()
                    .fill(color.opacity(0.9))
                    .frame(width: max(0, proxy.size.width * (isCompleted ? 1 : 0)), height: 2.8)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .animation(.spring(response: 0.32, dampingFraction: 0.78), value: isCompleted)
            }
            .allowsHitTesting(false)
        }
    }
}
