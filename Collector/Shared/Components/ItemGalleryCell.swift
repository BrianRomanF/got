import SwiftUI

struct ItemGalleryCell: View {
    let item: CollectibleItem

    var body: some View {
        HStack(spacing: 14) {
            CoverImageView(
                title: item.title,
                ownershipStatus: item.ownershipStatus,
                localImageData: item.coverImageData,
                localImagePath: item.coverLocalImagePath,
                remoteImageURL: item.coverRemoteURL,
                ownedFill: ComicTheme.red,
                placeholderSymbolName: "photo.on.rectangle.angled",
                showsTitle: false
            )
            .frame(width: 96, height: 132)

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    OwnershipBadge(status: item.ownershipStatus)

                    if let readingStatus = item.readingStatus {
                        ReadingBadge(status: readingStatus)
                    }
                }

                Text(item.title)
                    .font(.headline.weight(.black))
                    .foregroundStyle(ComicTheme.ink)
                    .lineLimit(2)

                if !item.subtitle.isEmpty {
                Text(item.subtitle)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(ComicTheme.ink.opacity(0.68))
                    .lineLimit(2)
            }

            ItemTagChipsView(tags: item.tags, limit: 3)

                if let rating = item.bookRating, rating > 0 {
                    HStack(spacing: 4) {
                        ForEach(1...5, id: \.self) { value in
                            Image(systemName: value <= rating ? "star.fill" : "star")
                                .font(.caption.weight(.black))
                                .foregroundStyle(value <= rating ? ComicTheme.yellow : ComicTheme.ink.opacity(0.35))
                        }
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .comicPanel(fill: ComicTheme.panel)
    }
}
