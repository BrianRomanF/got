import SwiftUI

struct ComicFollowSeriesButton: View {
    let isFollowing: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 5) {
                Image(systemName: isFollowing ? "bookmark.fill" : "bookmark")
                Text(isFollowing ? L10n.ComicFollowing.following : L10n.ComicFollowing.followShort)
            }
            .font(.caption.weight(.black))
            .foregroundStyle(ComicTheme.ink)
            .padding(.horizontal, 10)
            .frame(minHeight: 44)
            .background(isFollowing ? ComicTheme.panel : Color.white, in: RoundedRectangle(cornerRadius: 7))
            .overlay(RoundedRectangle(cornerRadius: 7).stroke(ComicTheme.ink, lineWidth: 2))
        }
        .buttonStyle(.plain)
        .accessibilityHint(L10n.ComicFollowing.hint)
        .accessibilityAddTraits(isFollowing ? .isSelected : [])
    }
}
