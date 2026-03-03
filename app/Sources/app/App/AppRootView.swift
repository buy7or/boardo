import SwiftUI

enum AppTab {
    case board
    case settings
}

struct AppRootView: View {
    @State private var selectedTab: AppTab = .board

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .board:
                    BoardScreen(viewModel: BoardViewModel(), showsBottomNavigation: false)
                case .settings:
                    SettingsScreen()
                }
            }

            BottomNavigationBar(selectedTab: selectedTab) { tab in
                selectedTab = tab
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 10)
        }
    }
}
