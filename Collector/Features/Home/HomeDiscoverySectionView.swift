import SwiftUI

struct HomeDiscoverySectionView: View {
    @EnvironmentObject private var library: CollectionLibraryController
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var controller = HomeDiscoveryController()
    @State private var needsNewSuggestion = true

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
        .onChange(of: scenePhase, initial: true) { _, phase in
            if phase == .background {
                needsNewSuggestion = true
            } else if phase == .active, needsNewSuggestion {
                controller.refresh(categories: library.categories, chooseAnother: true)
                needsNewSuggestion = false
            }
        }
        .onAppear {
            if controller.suggestion == nil {
                controller.refresh(categories: library.categories)
                if scenePhase == .active { needsNewSuggestion = false }
            }
        }
    }
}
