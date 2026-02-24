import SwiftUI

struct TaskSectionHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundStyle(AppTheme.Colors.title)

            Spacer()

            Text(subtitle)
                .font(.caption)
                .foregroundStyle(AppTheme.Colors.subtitle)
        }
    }
}
