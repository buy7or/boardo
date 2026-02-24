import SwiftUI

struct AppRootView: View {
    var body: some View {
        BoardScreen(viewModel: BoardViewModel())
    }
}
