import SwiftUI

enum AppTab: Int, Hashable {
    case board
    case settings
}

struct AppRootView: View {
    @State private var selectedTab: AppTab = .board
    @State private var boardViewModel = BoardViewModel()
    @State private var isBottomNavigationHidden = false

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                BoardScreen(
                    viewModel: boardViewModel,
                    showsBottomNavigation: false,
                    onBottomNavigationVisibilityChange: { isHidden in
                        isBottomNavigationHidden = isHidden
                    }
                )
                .tag(AppTab.board)

                SettingsScreen()
                    .tag(AppTab.settings)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
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
}
