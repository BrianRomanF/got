import SwiftUI

struct ComicFollowSeriesButton: View {
    let isFollowing: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                Image(systemName: isFollowing ? "bookmark.fill" : "bookmark")
                    .font(.title3.weight(.black))
                VStack(alignment: .leading, spacing: 4) {
                    Text(isFollowing ? L10n.ComicFollowing.following : L10n.ComicFollowing.follow)
                        .font(.headline.weight(.black))
                    Text(L10n.ComicFollowing.hint)
                        .font(.caption.weight(.semibold))
                        .multilineTextAlignment(.leading)
                }
                Spacer(minLength: 0)
                Image(systemName: isFollowing ? "checkmark.circle.fill" : "plus.circle")
                    .font(.headline.weight(.black))
            }
            .foregroundStyle(ComicTheme.ink)
            .padding(16)
            .comicPanel(fill: isFollowing ? ComicTheme.yellow : ComicTheme.panel)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isFollowing ? .isSelected : [])
    }
}
