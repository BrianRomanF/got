import SwiftUI

struct ComicSeriesHeaderSummaryView: View {
    let progress: ComicSeriesProgress
    let isFollowing: Bool
    let onToggleFollowing: () -> Void

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 12) {
                counts.fixedSize(horizontal: true, vertical: false)
                Spacer(minLength: 0)
                followButton
            }
            VStack(alignment: .leading, spacing: 10) {
                counts
                followButton
            }
        }
    }

    private var counts: some View {
        HStack(spacing: 12) {
            Text("\(L10n.ComicWidgets.owned) \(progress.ownedIssues)")
            Text("\(L10n.ComicWidgets.missing) \(progress.missingIssues)")
        }
        .font(.caption.weight(.black))
        .foregroundStyle(ComicTheme.ink)
    }

    private var followButton: some View {
        ComicFollowSeriesButton(isFollowing: isFollowing, onToggle: onToggleFollowing)
            .fixedSize(horizontal: true, vertical: false)
    }
}
