import SwiftUI

@main
struct CollectorApp: App {
    @StateObject private var libraryController = CollectionLibraryController()
    @StateObject private var proAccessController = ProAccessController()
    @AppStorage(AppSettings.selectedLanguageKey) private var selectedLanguage = AppLanguage.system.rawValue
    @AppStorage(AppSettings.hideOnboardingKey) private var hideOnboarding = false

    var body: some Scene {
        WindowGroup {
            if hideOnboarding {
                HomeView()
                    .environmentObject(libraryController)
                    .environmentObject(proAccessController)
                    .environment(\.locale, Locale(identifier: currentLocaleIdentifier))
            } else {
                OnboardingView {
                    hideOnboarding = true
                }
                .environmentObject(proAccessController)
                .environment(\.locale, Locale(identifier: currentLocaleIdentifier))
            }
        }
    }

    private var currentLocaleIdentifier: String {
        AppLanguage(rawValue: selectedLanguage)?.localeIdentifier ?? Locale.autoupdatingCurrent.identifier
    }
}
