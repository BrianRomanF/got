import SwiftUI

struct HomeCategoryCell: View {
    let category: CollectionCategory
    let stats: CollectionStats

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            CategoryIconView(category: category, size: 58, symbolSize: 34)

            VStack(alignment: .leading, spacing: 4) {
                Text(category.title.uppercased())
                    .font(.system(.headline, design: .rounded).weight(.black))
                    .foregroundStyle(ComicTheme.ink)
                    .lineLimit(2)

                Text(category.subtitle)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(ComicTheme.ink.opacity(0.72))
                    .lineLimit(2)
            }

            VStack(alignment: .leading, spacing: 8) {
                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(ComicTheme.paper)
                        Capsule()
                            .fill(ComicTheme.green)
                            .frame(width: stats.completionRatio > 0 ? max(6, proxy.size.width * stats.completionRatio) : 0)
                    }
                }
                .frame(height: 10)
                .overlay(
                    Capsule()
                        .stroke(ComicTheme.ink, lineWidth: 1.5)
                )

                Text(String(format: L10n.Dashboard.categoryProgress, stats.ownedItems, stats.totalItems))
                    .font(.caption2.weight(.black))
                    .foregroundStyle(ComicTheme.ink.opacity(0.72))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, minHeight: 170, alignment: .topLeading)
        .padding(14)
        .comicPanel(fill: ComicTheme.panel)
    }
}
