import Foundation

enum L10n {
    static let languagePreferenceKey = "app_language_code"
    static let supportedLanguageCodes = ["es", "en"]

    static func defaultSupportedLanguageCode() -> String {
        let preferred = Locale.preferredLanguages.first ?? "en"
        return preferred.hasPrefix("es") ? "es" : "en"
    }

    static func normalizedSupportedLanguageCode(_ code: String?) -> String {
        guard let code else { return defaultSupportedLanguageCode() }
        if supportedLanguageCodes.contains(code) {
            return code
        }
        return defaultSupportedLanguageCode()
    }

    static func currentLocale() -> Locale {
        Locale(identifier: normalizedSupportedLanguageCode(UserDefaults.standard.string(forKey: languagePreferenceKey)))
    }

    static func currentLocale(languageCode: String?) -> Locale {
        Locale(identifier: normalizedSupportedLanguageCode(languageCode))
    }

    static func tr(_ key: String) -> String {
        tr(key, languageCode: UserDefaults.standard.string(forKey: languagePreferenceKey))
    }

    static func tr(_ key: String, languageCode: String?) -> String {
        let code = normalizedSupportedLanguageCode(languageCode)
        let localizedBundle = bundle(languageCode: code)
        return NSLocalizedString(key, tableName: "Localizable", bundle: localizedBundle, value: key, comment: "")
    }

    private static func bundle(languageCode: String) -> Bundle {
        guard let path = Bundle.module.path(forResource: languageCode, ofType: "lproj"),
              let localizedBundle = Bundle(path: path) else {
            return .module
        }
        return localizedBundle
    }
}
