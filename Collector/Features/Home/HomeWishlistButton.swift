import SwiftUI

struct HomeWishlistButton: View {
    let missingCount: Int

    var body: some View {
        NavigationLink(value: CollectorRoute.wishlist) {
            HStack(spacing: 12) {
                Image(systemName: "heart.text.square.fill")
                    .font(.title3.weight(.black))
                    .foregroundStyle(ComicTheme.red)

                VStack(alignment: .leading, spacing: 3) {
                    Text(L10n.Wishlist.title.uppercased().vintageSafe)
                        .font(.headline.weight(.black))
                        .foregroundStyle(ComicTheme.ink)

                    Text(String(format: L10n.Wishlist.count, missingCount))
                        .font(.caption.weight(.bold))
                        .foregroundStyle(ComicTheme.ink.opacity(0.72))
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.headline.weight(.black))
                    .foregroundStyle(ComicTheme.ink.opacity(0.65))
            }
            .padding(16)
            .comicPanel(fill: ComicTheme.panel)
        }
        .buttonStyle(.plain)
    }
}
