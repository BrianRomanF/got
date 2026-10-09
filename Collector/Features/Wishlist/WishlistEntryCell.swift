import SwiftUI

struct WishlistEntryCell: View {
    let entry: WishlistEntry

    var body: some View {
        HStack(spacing: 12) {
            CoverImageView(
                title: entry.item.title,
                ownershipStatus: entry.item.ownershipStatus,
                localImageData: entry.item.coverImageData,
                localImagePath: entry.item.coverLocalImagePath,
                remoteImageURL: entry.item.coverRemoteURL,
                ownedFill: ComicTheme.red,
                placeholderSymbolName: "heart.fill",
                showsTitle: false
            )
            .frame(width: 72, height: 96)

            VStack(alignment: .leading, spacing: 6) {
                Text(entry.item.title)
                    .font(.headline.weight(.black))
                    .foregroundStyle(ComicTheme.ink)
                    .lineLimit(2)

                Text([entry.categoryTitle, entry.groupTitle].compactMap { $0 }.joined(separator: " > "))
                    .font(.caption.weight(.bold))
                    .foregroundStyle(ComicTheme.ink.opacity(0.68))
                    .lineLimit(2)

                ItemTagChipsView(tags: entry.item.tags, limit: 3)

                OwnershipBadge(status: entry.item.ownershipStatus)
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .comicPanel(fill: ComicTheme.panel)
    }
}
