import SwiftUI

struct WishlistCategoryCell: View {
    let summary: WishlistCategorySummary

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "square.grid.2x2.fill")
                .font(.title2.weight(.black))
                .foregroundStyle(ComicTheme.red)
                .frame(width: 48, height: 48)
                .background(ComicTheme.yellow)
                .overlay(
                    RoundedRectangle(cornerRadius: 7)
                        .stroke(ComicTheme.ink, lineWidth: 2)
                )
                .clipShape(RoundedRectangle(cornerRadius: 7))

            VStack(alignment: .leading, spacing: 4) {
                Text(summary.title.uppercased().vintageSafe)
                    .font(.headline.weight(.black))
                    .foregroundStyle(ComicTheme.ink)
                    .lineLimit(2)

                Text(String(format: L10n.Wishlist.count, summary.count))
                    .font(.caption.weight(.bold))
                    .foregroundStyle(ComicTheme.ink.opacity(0.7))
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.headline.weight(.black))
                .foregroundStyle(ComicTheme.ink.opacity(0.65))
        }
        .padding(14)
        .comicPanel(fill: ComicTheme.panel)
    }
}
