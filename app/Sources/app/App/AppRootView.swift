import SwiftUI

enum AppTab: Int, Hashable {
    case board
    case settings
}

struct AppRootView: View {
    @State private var selectedTab: AppTab = .board
    @State private var boardViewModel = BoardViewModel()
    @State private var isBottomNavigationHidden = false
    @State private var isTabPagingLocked = false
    @GestureState private var dragTranslation: CGFloat = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    BoardScreen(
                        viewModel: boardViewModel,
                        showsBottomNavigation: false,
                        onBottomNavigationVisibilityChange: { isHidden in
                            isBottomNavigationHidden = isHidden
                        },
                        onPagingLockChange: { isLocked in
                            isTabPagingLocked = isLocked
                        }
                    )
                    .frame(width: geometry.size.width)

                    SettingsScreen()
                        .frame(width: geometry.size.width)
                }
                .frame(width: geometry.size.width * 2, alignment: .leading)
                .offset(x: pageOffset(for: geometry.size.width))
                .animation(.interactiveSpring(response: 0.34, dampingFraction: 0.86), value: selectedTab)
                .animation(.interactiveSpring(response: 0.22, dampingFraction: 0.92), value: dragTranslation)
                .contentShape(Rectangle())
                .gesture(pageDragGesture(pageWidth: geometry.size.width))
            }
            .ignoresSafeArea(edges: .bottom)

            BottomNavigationBar(selectedTab: selectedTab) { tab in
                withAnimation(.spring(response: 0.36, dampingFraction: 0.86)) {
                    selectedTab = tab
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 10)
            .opacity(selectedTab == .board && isBottomNavigationHidden ? 0 : 1)
            .offset(y: selectedTab == .board && isBottomNavigationHidden ? 140 : 0)
            .allowsHitTesting(!(selectedTab == .board && isBottomNavigationHidden))
            .animation(.spring(response: 0.28, dampingFraction: 0.86), value: isBottomNavigationHidden)
        }
    }

    private func pageOffset(for pageWidth: CGFloat) -> CGFloat {
        let baseOffset = -CGFloat(selectedTab.rawValue) * pageWidth
        let leadingLimit = CGFloat(AppTab.board.rawValue) * pageWidth
        let trailingLimit = -CGFloat(AppTab.settings.rawValue) * pageWidth
        return min(max(baseOffset + dragTranslation, trailingLimit), leadingLimit)
    }

    private func pageDragGesture(pageWidth: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 12)
            .updating($dragTranslation) { value, state, _ in
                guard !isTabPagingLocked else { return }
                guard abs(value.translation.width) > abs(value.translation.height) else { return }
                state = value.translation.width
            }
            .onEnded { value in
                guard !isTabPagingLocked else { return }
                guard abs(value.translation.width) > abs(value.translation.height) else { return }

                let threshold = pageWidth * 0.2
                let predicted = value.predictedEndTranslation.width

                if selectedTab == .board && (value.translation.width < -threshold || predicted < -pageWidth * 0.35) {
                    selectedTab = .settings
                } else if selectedTab == .settings && (value.translation.width > threshold || predicted > pageWidth * 0.35) {
                    selectedTab = .board
                }
            }
    }
}
