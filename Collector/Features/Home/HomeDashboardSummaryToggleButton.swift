import SwiftUI

struct HomeDashboardSummaryToggleButton: View {
    let stats: CollectionStats
    let isExpanded: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(L10n.Dashboard.title.uppercased().vintageSafe)
                            .font(.caption.weight(.black))
                            .foregroundStyle(ComicTheme.red)

                        Text(L10n.Dashboard.subtitle)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(ComicTheme.ink.opacity(0.72))
                    }

                    Spacer(minLength: 0)

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption.weight(.black))
                        .foregroundStyle(ComicTheme.ink)
                        .accessibilityHidden(true)

                    Text("\(Int(stats.completionRatio * 100))%")
                        .font(ComicTheme.titleFont)
                        .foregroundStyle(ComicTheme.ink)
                        .minimumScaleFactor(0.7)
                }

                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(ComicTheme.paper)
                        Capsule()
                            .fill(ComicTheme.green)
                            .frame(width: stats.completionRatio > 0 ? max(8, proxy.size.width * stats.completionRatio) : 0)
                    }
                }
                .frame(height: 14)
                .overlay(
                    Capsule()
                        .stroke(ComicTheme.ink, lineWidth: 2)
                )
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityHint(isExpanded ? L10n.Dashboard.collapseDetails : L10n.Dashboard.expandDetails)
    }
}
