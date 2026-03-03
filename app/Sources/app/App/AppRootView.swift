import SwiftUI

enum AppTab {
    case board
    case settings
}

struct AppRootView: View {
    @State private var selectedTab: AppTab = .board
    @State private var isBottomNavigationHidden = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .board:
                    BoardScreen(
                        viewModel: BoardViewModel(),
                        showsBottomNavigation: false,
                        onBottomNavigationVisibilityChange: { isHidden in
                            isBottomNavigationHidden = isHidden
                        }
                    )
                case .settings:
                    SettingsScreen()
                }
            }

            BottomNavigationBar(selectedTab: selectedTab) { tab in
                selectedTab = tab
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 10)
            .opacity(selectedTab == .board && isBottomNavigationHidden ? 0 : 1)
            .offset(y: selectedTab == .board && isBottomNavigationHidden ? 140 : 0)
            .allowsHitTesting(!(selectedTab == .board && isBottomNavigationHidden))
            .animation(.spring(response: 0.28, dampingFraction: 0.86), value: isBottomNavigationHidden)
        }
    }
}
