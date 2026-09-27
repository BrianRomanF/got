import SwiftUI

struct ItemDetailCoverView: View {
    let item: CollectibleItem

    var body: some View {
        ZStack(alignment: .topTrailing) {
            CoverImageView(
                title: item.title,
                ownershipStatus: item.ownershipStatus,
                localImageData: item.coverImageData,
                localImagePath: item.coverLocalImagePath,
                remoteImageURL: item.coverRemoteURL,
                ownedFill: ComicTheme.blue,
                placeholderSymbolName: "photo.artframe",
                showsTitle: true
            )

            OwnershipBadge(status: item.ownershipStatus)
                .padding(14)
        }
        .comicPanel(fill: ComicTheme.panel)
    }
}
