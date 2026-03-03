import SwiftUI

extension View {
    func pullDownToDismiss(
        enabled: Bool = true,
        startRegionHeight: CGFloat = 140,
        dismissThreshold: CGFloat = 120,
        onDismiss: @escaping () -> Void
    ) -> some View {
        modifier(
            PullDownToDismissModifier(
                enabled: enabled,
                startRegionHeight: startRegionHeight,
                dismissThreshold: dismissThreshold,
                onDismiss: onDismiss
            )
        )
    }
}

private struct PullDownToDismissModifier: ViewModifier {
    let enabled: Bool
    let startRegionHeight: CGFloat
    let dismissThreshold: CGFloat
    let onDismiss: () -> Void

    @State private var offsetY: CGFloat = 0
    @State private var isDraggingFromTop = false

    func body(content: Content) -> some View {
        content
            .offset(y: offsetY)
            .scaleEffect(1 - min(offsetY / 2200, 0.04), anchor: .top)
            .rotationEffect(.degrees(min(offsetY / 80, 2.5)))
            .simultaneousGesture(
                DragGesture(minimumDistance: 10)
                    .onChanged { value in
                        guard enabled else { return }

                        if !isDraggingFromTop {
                            guard value.startLocation.y <= startRegionHeight else { return }
                            guard abs(value.translation.height) > abs(value.translation.width) else { return }
                            guard value.translation.height > 0 else { return }
                            isDraggingFromTop = true
                        }

                        let translation = max(value.translation.height, 0)
                        offsetY = min(translation, 220)
                    }
                    .onEnded { value in
                        guard enabled else { return }
                        guard isDraggingFromTop else { return }

                        let projectedHeight = max(value.predictedEndTranslation.height, value.translation.height)
                        let shouldDismiss = projectedHeight > dismissThreshold

                        if shouldDismiss {
                            withAnimation(.interactiveSpring(response: 0.28, dampingFraction: 0.9)) {
                                offsetY = 480
                            }
                            onDismiss()
                        } else {
                            withAnimation(.interactiveSpring(response: 0.28, dampingFraction: 0.86)) {
                                offsetY = 0
                            }
                        }

                        isDraggingFromTop = false
                    }
            )
    }
}
