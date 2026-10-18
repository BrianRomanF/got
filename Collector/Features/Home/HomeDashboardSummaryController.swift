import Foundation

@MainActor
final class HomeDashboardSummaryController: ObservableObject {
    @Published private(set) var isExpanded = false

    func toggleDetails() {
        isExpanded.toggle()
    }
}
