import SwiftUI

struct SettingsScreen: View {
    @Bindable var viewModel: BoardViewModel
    @State private var statusMessage = "Pulsa el boton para programar una notificacion de prueba."
    @State private var showCategoryManager = false
    private let scheduler = NotificationScheduler()

    var body: some View {
        BoardSurface {
            VStack(spacing: 20) {
                Spacer(minLength: 0)

                VStack(spacing: 12) {
                    Text("Settings")
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(AppTheme.Colors.title)

                    Text(statusMessage)
                        .font(.body)
                        .foregroundStyle(AppTheme.Colors.subtitle)
                        .multilineTextAlignment(.center)
                }

                Button {
                    Task {
                        await scheduleNotification()
                    }
                } label: {
                    Text("Programar notificacion")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppTheme.Colors.accent)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous))
                        .shadow(color: AppTheme.Shadow.card, radius: 10, x: 0, y: 6)
                }
                .buttonStyle(.plain)

                Button {
                    showCategoryManager = true
                } label: {
                    Label("Gestionar categorias", systemImage: "square.grid.2x2.fill")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(AppTheme.Colors.accent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.white)
                        .overlay {
                            RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous)
                                .stroke(AppTheme.Colors.accent.opacity(0.35), lineWidth: 1)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous))
                }
                .buttonStyle(.plain)

                Text("La notificacion llegara en 10 segundos.")
                    .font(.caption)
                    .foregroundStyle(AppTheme.Colors.subtitle)

                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 40)
            .padding(.bottom, 110)
        }
        .sheet(isPresented: $showCategoryManager) {
            CategoryManagerSheet(viewModel: viewModel)
        }
    }

    @MainActor
    private func scheduleNotification() async {
        do {
            try await scheduler.requestAuthorizationIfNeeded()
            try await scheduler.scheduleTestNotification(after: 10)
            statusMessage = "Notificacion programada. Bloquea el iPhone o manda la app al fondo y espera 10 segundos."
        } catch {
            statusMessage = "No se pudo programar la notificacion. Revisa los permisos de notificaciones para Boardo."
        }
    }
}
