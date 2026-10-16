import SwiftUI

struct HomeDiscoverySectionView: View {
    @EnvironmentObject private var library: CollectionLibraryController
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var controller = HomeDiscoveryController()

    var body: some View {
        VStack(spacing: 0) {
            if let suggestion = controller.suggestion {
                HomeDiscoveryCardView(suggestion: suggestion, canShowAnother: controller.canShowAnother) {
                    controller.showAnother()
                }
            }
        }
        .onChange(of: library.categories) { _, categories in
            controller.refresh(categories: categories)
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { controller.refresh(categories: library.categories) }
        }
        .task {
            controller.refresh(categories: library.categories)
            while !Task.isCancelled {
                let calendar = Calendar.current
                guard let nextDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: .now)) else { return }
                do {
                    try await Task.sleep(for: .seconds(max(1, nextDay.timeIntervalSinceNow)))
                } catch { return }
                controller.refresh(categories: library.categories)
            }
        }
    }
}
