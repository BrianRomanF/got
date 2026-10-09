import SwiftUI

struct HomeDashboardSummaryView: View {
    let stats: CollectionStats
    let categoryCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.Dashboard.title.uppercased().vintageSafe)
                        .font(.caption.weight(.black))
                        .foregroundStyle(ComicTheme.red)

                    Text(L10n.Dashboard.subtitle)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(ComicTheme.ink.opacity(0.72))
                }

                Spacer(minLength: 0)

                Text("\(Int(stats.completionRatio * 100))%")
                    .font(ComicTheme.titleFont)
                    .foregroundStyle(ComicTheme.ink)
                    .minimumScaleFactor(0.7)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(ComicTheme.paper)
                    Capsule()
                        .fill(ComicTheme.green)
                        .frame(width: stats.completionRatio > 0 ? max(8, proxy.size.width * stats.completionRatio) : 0)
                }
            }
            .frame(height: 14)
            .overlay(
                Capsule()
                    .stroke(ComicTheme.ink, lineWidth: 2)
            )

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
        .padding(16)
        .comicPanel(fill: ComicTheme.yellow)
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
