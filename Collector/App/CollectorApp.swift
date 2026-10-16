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
    @AppStorage(AppSettings.hasCompletedOnboardingKey) private var hasCompletedOnboarding = false
    @State private var isShowingOnboarding = false

    var body: some Scene {
        WindowGroup {
            ZStack {
                if hasCompletedOnboarding && !isShowingOnboarding {
                    HomeView()
                        .environmentObject(libraryController)
                        .environmentObject(proAccessController)
                        .environmentObject(libraryController.syncStateController)
                        .environmentObject(cloudKitCoordinator)
                        .environment(\.locale, Locale(identifier: currentLocaleIdentifier))
                } else {
                    OnboardingView {
                        hasCompletedOnboarding = true
                        isShowingOnboarding = false
                    }
                    .environmentObject(proAccessController)
                    .environmentObject(libraryController.syncStateController)
                    .environmentObject(cloudKitCoordinator)
                    .environment(\.locale, Locale(identifier: currentLocaleIdentifier))
                }
            }
            .task {
                isShowingOnboarding = !hideOnboarding
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else { return }
            WidgetDashboardPublisher.publish(categories: libraryController.categories)

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
