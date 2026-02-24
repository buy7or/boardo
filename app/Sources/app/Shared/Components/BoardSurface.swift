import SwiftUI

struct BoardSurface<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    AppTheme.Colors.boardBackground,
                    Color.white
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            content
        }
    }
}
