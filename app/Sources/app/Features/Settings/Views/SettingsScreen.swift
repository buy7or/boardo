import SwiftUI

struct SettingsScreen: View {
    private enum StatusMessage {
        case initial
        case disabled
        case timeSaved
        case invalidTime
        case enabledAt
        case permissionError
    }

    @Bindable var viewModel: BoardViewModel
    @State private var statusMessage: StatusMessage = .initial
    @State private var showCategoryManager = false
    @State private var dailyNotificationsEnabled: Bool
    @State private var notificationTime: Date
    @State private var selectedLanguageCode: String
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

        _selectedLanguageCode = State(
            initialValue: L10n.normalizedSupportedLanguageCode(
                UserDefaults.standard.string(forKey: L10n.languagePreferenceKey)
            )
        )
    }

    var body: some View {
        BoardSurface {
            VStack(spacing: 20) {
                Spacer(minLength: 0)

                VStack(spacing: 12) {
                    Text(tr("settings.title"))
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(AppTheme.Colors.title)

                    Text(localizedStatusMessage)
                        .font(.body)
                        .foregroundStyle(AppTheme.Colors.subtitle)
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: 14) {
                    Toggle(isOn: $dailyNotificationsEnabled) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(tr("settings.notifications.label"))
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(AppTheme.Colors.title)
                            Text(tr("settings.notifications.description"))
                                .font(.caption)
                                .foregroundStyle(AppTheme.Colors.subtitle)
                        }
                    }

                    DatePicker(
                        tr("settings.notifications.timePicker"),
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
                .onChange(of: dailyNotificationsEnabled) { _, isEnabled in
                    Task {
                        await handleNotificationToggleChange(isEnabled)
                    }
                }
                .onChange(of: notificationTime) { _, _ in
                    Task {
                        await handleNotificationTimeChange()
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text(tr("settings.language.title"))
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(AppTheme.Colors.title)

                    Picker(tr("settings.language.title"), selection: $selectedLanguageCode) {
                        Text(tr("settings.language.spanish")).tag("es")
                        Text(tr("settings.language.english")).tag("en")
                    }
                    .pickerStyle(.segmented)
                }
                .padding(16)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous))
                .shadow(color: AppTheme.Shadow.card, radius: 10, x: 0, y: 6)
                .onChange(of: selectedLanguageCode) { _, newValue in
                    UserDefaults.standard.set(newValue, forKey: L10n.languagePreferenceKey)
                }

                Button {
                    showCategoryManager = true
                } label: {
                    Label(tr("settings.manageCategories"), systemImage: "square.grid.2x2.fill")
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
            statusMessage = .disabled
        }
    }

    @MainActor
    private func handleNotificationTimeChange() async {
        persistPreferences()

        if dailyNotificationsEnabled {
            await scheduleDailyNotificationIfPossible()
        } else {
            statusMessage = .timeSaved
        }
    }

    @MainActor
    private func scheduleDailyNotificationIfPossible() async {
        let components = Calendar.current.dateComponents([.hour, .minute], from: notificationTime)
        guard let hour = components.hour, let minute = components.minute else {
            statusMessage = .invalidTime
            return
        }

        do {
            try await scheduler.requestAuthorizationIfNeeded()
            try await scheduler.scheduleDailyNotification(hour: hour, minute: minute)
            statusMessage = .enabledAt
        } catch {
            dailyNotificationsEnabled = false
            scheduler.cancelDailyNotification()
            persistPreferences()
            statusMessage = .permissionError
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
        formatter.locale = L10n.currentLocale(languageCode: selectedLanguageCode)
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: date)
    }

    private var localizedStatusMessage: String {
        switch statusMessage {
        case .initial:
            return tr("settings.notifications.status.initial")
        case .disabled:
            return tr("settings.notifications.status.disabled")
        case .timeSaved:
            return tr("settings.notifications.status.timeSaved")
        case .invalidTime:
            return tr("settings.notifications.status.invalidTime")
        case .enabledAt:
            return String(
                format: tr("settings.notifications.status.enabledAt"),
                formattedTime(notificationTime)
            )
        case .permissionError:
            return tr("settings.notifications.status.permissionError")
        }
    }

    private func tr(_ key: String) -> String {
        L10n.tr(key, languageCode: selectedLanguageCode)
    }
}
