import SwiftUI

struct BottomNavigationBar: View {
    var body: some View {
        HStack(spacing: 28) {
            navItem(icon: "square.grid.2x2.fill", title: "Board", selected: true)
            navItem(icon: "calendar", title: "Schedule", selected: false)
            navItem(icon: "gearshape.fill", title: "Settings", selected: false)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 22)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.large, style: .continuous))
        .shadow(color: AppTheme.Shadow.card, radius: 14, x: 0, y: 8)
    }

    private func navItem(icon: String, title: String, selected: Bool) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .semibold))
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .foregroundStyle(selected ? AppTheme.Colors.accent : AppTheme.Colors.subtitle)
        .frame(maxWidth: .infinity)
    }
}
