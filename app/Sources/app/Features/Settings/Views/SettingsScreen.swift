import SwiftUI

struct SettingsScreen: View {
    @Bindable var viewModel: BoardViewModel
    @State private var statusMessage = "Configura la notificacion diaria y activa el recordatorio."
    @State private var showCategoryManager = false
    @State private var dailyNotificationsEnabled: Bool
    @State private var notificationTime: Date
    private let scheduler = NotificationScheduler()
    private let preferencesStore = NotificationPreferencesStore()

    init(viewModel: BoardViewModel) {
        self.viewModel = viewModel

        let now = Date()
        let calendar = Calendar.current

        if let preferences = NotificationPreferencesStore().loadPreferences() {
            _dailyNotificationsEnabled = State(initialValue: preferences.isEnabled)

            let date = calendar.date(
                bySettingHour: preferences.hour,
                minute: preferences.minute,
                second: 0,
                of: now
            ) ?? now
            _notificationTime = State(initialValue: date)
        } else {
            _dailyNotificationsEnabled = State(initialValue: false)
            let defaultDate = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: now) ?? now
            _notificationTime = State(initialValue: defaultDate)
        }
    }

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

                VStack(spacing: 14) {
                    Toggle(isOn: $dailyNotificationsEnabled) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Notificacion diaria")
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(AppTheme.Colors.title)
                            Text("Recibe un recordatorio cada dia a la hora elegida.")
                                .font(.caption)
                                .foregroundStyle(AppTheme.Colors.subtitle)
                        }
                    }

                    DatePicker(
                        "Hora del recordatorio",
                        selection: $notificationTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .opacity(dailyNotificationsEnabled ? 1 : 0.45)
                }
                .padding(16)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous))
                .shadow(color: AppTheme.Shadow.card, radius: 10, x: 0, y: 6)
                .onChange(of: dailyNotificationsEnabled) { isEnabled in
                    Task {
                        await handleNotificationToggleChange(isEnabled)
                    }
                }
                .onChange(of: notificationTime) { _ in
                    Task {
                        await handleNotificationTimeChange()
                    }
                }

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
    private func handleNotificationToggleChange(_ isEnabled: Bool) async {
        persistPreferences()

        if isEnabled {
            await scheduleDailyNotificationIfPossible()
        } else {
            scheduler.cancelDailyNotification()
            statusMessage = "Recordatorio diario desactivado."
        }
    }

    @MainActor
    private func handleNotificationTimeChange() async {
        persistPreferences()

        if dailyNotificationsEnabled {
            await scheduleDailyNotificationIfPossible()
        } else {
            statusMessage = "Hora guardada. Activa la notificacion diaria para programarla."
        }
    }

    @MainActor
    private func scheduleDailyNotificationIfPossible() async {
        let components = Calendar.current.dateComponents([.hour, .minute], from: notificationTime)
        guard let hour = components.hour, let minute = components.minute else {
            statusMessage = "No se pudo leer la hora seleccionada."
            return
        }

        do {
            try await scheduler.requestAuthorizationIfNeeded()
            try await scheduler.scheduleDailyNotification(hour: hour, minute: minute)
            statusMessage = "Notificacion diaria activa a las \(formattedTime(notificationTime))."
        } catch {
            dailyNotificationsEnabled = false
            scheduler.cancelDailyNotification()
            persistPreferences()
            statusMessage = "No se pudo activar la notificacion diaria. Revisa los permisos de Boardo."
        }
    }

    private func persistPreferences() {
        let components = Calendar.current.dateComponents([.hour, .minute], from: notificationTime)
        let hour = components.hour ?? 9
        let minute = components.minute ?? 0
        let preferences = NotificationPreferences(
            isEnabled: dailyNotificationsEnabled,
            hour: hour,
            minute: minute
        )
        preferencesStore.savePreferences(preferences)
    }

    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: date)
    }
}
