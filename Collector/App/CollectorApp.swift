import SwiftUI

@main
struct CollectorApp: App {
    @StateObject private var libraryController = CollectionLibraryController()
    @StateObject private var proAccessController = ProAccessController()
    @StateObject private var cloudKitCoordinator = CloudKitSyncCoordinator(
        syncStateController: .shared
    )
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage(AppSettings.selectedLanguageKey) private var selectedLanguage = AppLanguage.system.rawValue
    @AppStorage(AppSettings.hideOnboardingKey) private var hideOnboarding = false

    var body: some Scene {
        WindowGroup {
            if hideOnboarding {
                HomeView()
                    .environmentObject(libraryController)
                    .environmentObject(proAccessController)
                    .environmentObject(libraryController.syncStateController)
                    .environmentObject(cloudKitCoordinator)
                    .environment(\.locale, Locale(identifier: currentLocaleIdentifier))
            } else {
                OnboardingView {
                    hideOnboarding = true
                }
                .environmentObject(proAccessController)
                .environmentObject(libraryController.syncStateController)
                .environmentObject(cloudKitCoordinator)
                .environment(\.locale, Locale(identifier: currentLocaleIdentifier))
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else { return }

            Task {
                await proAccessController.refresh()
                await cloudKitCoordinator.refreshAccountStatus()
                await cloudKitCoordinator.synchronizeAutomatically(
                    localCategories: libraryController.categories
                )
            }
        }
    }

    private var currentLocaleIdentifier: String {
        AppLanguage(rawValue: selectedLanguage)?.localeIdentifier ?? Locale.autoupdatingCurrent.identifier
    }
}
