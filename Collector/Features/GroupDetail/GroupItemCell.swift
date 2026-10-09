import SwiftUI

struct GroupItemCell: View {
    let item: CollectibleItem

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .topTrailing) {
                CoverImageView(
                    title: item.title,
                    ownershipStatus: item.ownershipStatus,
                    localImageData: item.coverImageData,
                    localImagePath: item.coverLocalImagePath,
                    remoteImageURL: item.coverRemoteURL,
                    ownedFill: ComicTheme.blue,
                    placeholderSymbolName: "sparkles.rectangle.stack.fill",
                    showsTitle: false
                )

                OwnershipBadge(status: item.ownershipStatus)
                    .padding(8)
            }

            Text(item.title)
                .font(.subheadline.weight(.black))
                .foregroundStyle(ComicTheme.ink)
                .lineLimit(2)

            if let readingStatus = item.readingStatus {
                ReadingBadge(status: readingStatus)
            }

            ItemTagChipsView(tags: item.tags, limit: 2)
        }
        .padding(10)
        .comicPanel(fill: item.ownershipStatus == .owned ? ComicTheme.panel : Color.white.opacity(0.82))
    }
}
