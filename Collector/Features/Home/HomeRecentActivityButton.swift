import SwiftUI

struct HomeRecentActivityButton: View {
    let count: Int

    var body: some View {
        NavigationLink(value: CollectorRoute.recentActivity) {
            HStack(spacing: 14) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.title2.weight(.black))
                    .foregroundStyle(ComicTheme.ink)

                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.RecentActivity.title.uppercased().vintageSafe)
                        .font(.headline.weight(.black))
                        .foregroundStyle(ComicTheme.ink)

                    Text(String(format: L10n.RecentActivity.count, count))
                        .font(.caption.weight(.bold))
                        .foregroundStyle(ComicTheme.ink.opacity(0.68))
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.headline.weight(.black))
                    .foregroundStyle(ComicTheme.ink.opacity(0.64))
            }
            .padding(16)
            .comicPanel(fill: ComicTheme.yellow)
        }
        .buttonStyle(.plain)
    }
}
