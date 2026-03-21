import SwiftUI

struct BoardSurface<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.97, green: 0.91, blue: 0.78),
                    Color(red: 0.93, green: 0.85, blue: 0.70)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .overlay {
                // Soft cork-like texture using translucent dots.
                ZStack {
                    ForEach(0..<70, id: \.self) { index in
                        Circle()
                            .fill(Color.black.opacity(index.isMultiple(of: 2) ? 0.03 : 0.02))
                            .frame(width: CGFloat((index % 4) + 1), height: CGFloat((index % 4) + 1))
                            .position(
                                x: CGFloat((index * 47) % 390),
                                y: CGFloat((index * 83) % 860)
                            )
                    }
                }
            }
            .ignoresSafeArea()

            content
        }
    }
}
