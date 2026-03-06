import SwiftUI

struct BottomNavigationBar: View {
    @Namespace private var selectionAnimation
    let selectedTab: AppTab
    let onSelect: (AppTab) -> Void

    var body: some View {
        HStack(spacing: 12) {
            navItem(icon: "square.grid.2x2.fill", title: L10n.tr("tab.board"), selected: selectedTab == .board) {
                onSelect(.board)
            }
            navItem(icon: "chart.bar.xaxis", title: L10n.tr("tab.stats"), selected: selectedTab == .stats) {
                onSelect(.stats)
            }
            navItem(icon: "gearshape.fill", title: L10n.tr("tab.settings"), selected: selectedTab == .settings) {
                onSelect(.settings)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.94))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.large, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: AppTheme.Radius.large, style: .continuous)
                .strokeBorder(Color.white.opacity(0.9), lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.12), radius: 18, x: 0, y: 12)
    }

    private func navItem(icon: String, title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .symbolVariant(selected ? .fill : .none)

                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                    .opacity(selected ? 1 : 0.72)
            }
            .foregroundStyle(selected ? AppTheme.Colors.accent : AppTheme.Colors.subtitle)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .background {
                if selected {
                    Capsule(style: .continuous)
                        .fill(AppTheme.Colors.accent.opacity(0.14))
                        .matchedGeometryEffect(id: "selected-tab-pill", in: selectionAnimation)
                }
            }
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.32, dampingFraction: 0.82), value: selected)
    }
}
