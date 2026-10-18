import SwiftUI

struct HomeDiscoveryCardView: View {
    let suggestion: HomeDiscoverySuggestion
    let canShowAnother: Bool
    let onShowAnother: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(L10n.HomeDiscovery.title.uppercased().vintageSafe, systemImage: "sparkles")
                .font(.subheadline.weight(.black))
                .foregroundStyle(ComicTheme.red)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .center)

            HStack(alignment: .top, spacing: 20) {
                NavigationLink(value: suggestion.route) {
                    HomeDiscoveryCoverView(suggestion: suggestion)
                        .id(suggestion.id)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(suggestion.item.title)
                .accessibilityHint(L10n.HomeDiscovery.open)

                VStack(alignment: .leading, spacing: 6) {
                    NavigationLink(value: suggestion.route) {
                        HStack(spacing: 8) {
                            VStack(alignment: .leading, spacing: 7) {
                                Text(suggestion.prompt)
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(ComicTheme.red)
                                Text(suggestion.item.title)
                                    .font(.title3.weight(.black))
                                    .foregroundStyle(ComicTheme.ink)
                                    .lineLimit(3)
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

                    Spacer(minLength: 0)
                    if canShowAnother {
                        HomeDiscoveryShuffleButton(action: onShowAnother)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
                .frame(minHeight: suggestion.template == .vinyl ? 92 : 122, alignment: .topLeading)
            }
        }
        .padding(14)
        .comicPanel(fill: ComicTheme.panel)
    }
}
