import SwiftUI

struct InboxCard: View {
    let count: Int

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Inbox")
                    .font(.headline)
                    .foregroundStyle(AppTheme.Colors.title)
                Text("Tareas sin fecha")
                    .font(.caption)
                    .foregroundStyle(AppTheme.Colors.subtitle)
            }

            Spacer()

            Text("\(count)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(AppTheme.Colors.accent)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous))
        .shadow(color: AppTheme.Shadow.card, radius: 8, x: 0, y: 4)
    }
}
