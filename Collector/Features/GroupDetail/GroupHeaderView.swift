import SwiftUI

struct GroupHeaderView: View {
    let group: CollectionGroup
    var comicProgress: ComicSeriesProgress? = nil
    var onToggleFollowing: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(group.title.uppercased().vintageSafe)
                .font(ComicTheme.displayFont)
                .foregroundStyle(ComicTheme.ink)
                .lineLimit(3)
                .minimumScaleFactor(0.65)

            if !group.subtitle.isEmpty {
                Text(group.subtitle)
                    .font(ComicTheme.bodyFont)
                    .foregroundStyle(ComicTheme.ink.opacity(0.72))
            }
            if let comicProgress, let onToggleFollowing {
                ComicSeriesHeaderSummaryView(
                    progress: comicProgress,
                    isFollowing: group.isFollowing == true,
                    onToggleFollowing: onToggleFollowing
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .comicPanel(fill: ComicTheme.yellow)
    }
}
