import SwiftUI

struct HomeDiscoveryCardView: View {
    let suggestion: HomeDiscoverySuggestion
    let canShowAnother: Bool
    let onShowAnother: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Label(L10n.HomeDiscovery.title.uppercased().vintageSafe, systemImage: "sparkles")
                    .font(.caption.weight(.black))
                    .foregroundStyle(ComicTheme.red)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
                if canShowAnother { HomeDiscoveryShuffleButton(action: onShowAnother) }
            }
            NavigationLink(value: suggestion.route) {
                HStack(spacing: 12) {
                    HomeDiscoveryCoverView(suggestion: suggestion)
                        .id(suggestion.id)
                    VStack(alignment: .leading, spacing: 5) {
                        Text(suggestion.prompt)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(ComicTheme.red)
                        Text(suggestion.item.title)
                            .font(.headline.weight(.black))
                            .foregroundStyle(ComicTheme.ink)
                            .lineLimit(2)
                        Text(suggestion.categoryTitle)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(ComicTheme.ink.opacity(0.72))
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.black))
                        .foregroundStyle(ComicTheme.ink)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityHint(L10n.HomeDiscovery.open)
        }
        .padding(14)
        .comicPanel(fill: ComicTheme.panel)
    }
}
