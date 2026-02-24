import SwiftUI

struct BoardHeader: View {
    var body: some View {
        HStack {
            Button(action: {}) {
                Image(systemName: "line.3.horizontal")
                    .foregroundStyle(AppTheme.Colors.accent)
                    .frame(width: 34, height: 34)
                    .background(Color.white)
                    .clipShape(Circle())
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("My Workspace")
                    .font(.headline)
                    .foregroundStyle(AppTheme.Colors.title)
                Text("Let's get organized")
                    .font(.caption)
                    .foregroundStyle(AppTheme.Colors.subtitle)
            }

            Spacer()

            Text("7 DAY STREAK")
                .font(.caption2)
                .fontWeight(.bold)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(AppTheme.Colors.stickyYellow)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }
}
