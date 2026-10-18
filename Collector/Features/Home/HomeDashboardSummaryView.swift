import SwiftUI

struct HomeDashboardSummaryView: View {
    let stats: CollectionStats
    let categoryCount: Int
    @StateObject private var controller = HomeDashboardSummaryController()

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HomeDashboardSummaryToggleButton(stats: stats, isExpanded: controller.isExpanded) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    controller.toggleDetails()
                }
            }

            if controller.isExpanded {
                HomeDashboardSummaryStatsView(stats: stats, categoryCount: categoryCount)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(16)
        .comicPanel(fill: ComicTheme.yellow)
    }
}
