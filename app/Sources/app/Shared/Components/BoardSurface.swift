import SwiftUI

struct BoardSurface<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            content
        }
    }
}
