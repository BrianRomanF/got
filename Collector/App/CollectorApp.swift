import SwiftUI

@main
struct CollectorApp: App {
    @StateObject private var libraryController = CollectionLibraryController()
    @AppStorage(AppSettings.selectedLanguageKey) private var selectedLanguage = AppLanguage.system.rawValue
    @AppStorage(AppSettings.hideOnboardingKey) private var hideOnboarding = false

    var body: some Scene {
        WindowGroup {
            if hideOnboarding {
                HomeView()
                    .environmentObject(libraryController)
                    .environment(\.locale, Locale(identifier: currentLocaleIdentifier))
            } else {
                OnboardingView {
                    hideOnboarding = true
                }
                .environment(\.locale, Locale(identifier: currentLocaleIdentifier))
            }
        }
    }

    private var currentLocaleIdentifier: String {
        AppLanguage(rawValue: selectedLanguage)?.localeIdentifier ?? Locale.autoupdatingCurrent.identifier
    }
}
