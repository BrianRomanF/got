import SwiftUI

struct ItemDetailMetadataView: View {
    let item: CollectibleItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                OwnershipBadge(status: item.ownershipStatus)

                if let readingStatus = item.readingStatus {
                    ReadingBadge(status: readingStatus)
                }
            }

            Text(item.title.uppercased())
                .font(ComicTheme.displayFont)
                .foregroundStyle(ComicTheme.ink)
                .lineLimit(3)
                .minimumScaleFactor(0.65)

            if !item.subtitle.isEmpty {
                Text(item.subtitle)
                    .font(ComicTheme.bodyFont)
                    .foregroundStyle(ComicTheme.ink.opacity(0.72))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .comicPanel(fill: ComicTheme.yellow)
    }
}
