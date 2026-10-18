import SwiftUI

struct HomeDashboardSummaryStatsView: View {
    let stats: CollectionStats
    let categoryCount: Int

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                statBox(title: L10n.Dashboard.collections, value: categoryCount)
                statBox(title: L10n.Dashboard.pieces, value: stats.totalItems)
                statBox(title: L10n.Dashboard.missing, value: stats.missingItems)
            }

            HStack(spacing: 10) {
                statBox(title: L10n.Dashboard.shelves, value: stats.groups)
                statBox(title: L10n.Dashboard.tags, value: stats.uniqueTags)
                statBox(title: L10n.Dashboard.reading, value: stats.readingItems)
            }
        }
    }

    private func statBox(title: String, value: Int) -> some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.title3.weight(.black))
                .foregroundStyle(ComicTheme.ink)

            Text(title.uppercased().vintageSafe)
                .font(.caption2.weight(.black))
                .foregroundStyle(ComicTheme.ink.opacity(0.72))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 7)
                .stroke(ComicTheme.ink, lineWidth: 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 7))
    }
}
