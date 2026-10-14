import SwiftUI

struct ComicMissingIssuesView: View {
    let summary: ComicMissingIssueSummary

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: summary.missingCount == 0 ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                .font(.title3.weight(.black))
                .foregroundStyle(summary.missingCount == 0 ? ComicTheme.green : ComicTheme.red)

            VStack(alignment: .leading, spacing: 5) {
                Text(L10n.ComicMissingIssues.title.uppercased().vintageSafe)
                    .font(.caption.weight(.black))
                    .foregroundStyle(ComicTheme.ink.opacity(0.75))

                Text(summary.missingCount == 0 ? L10n.ComicMissingIssues.none : String(format: L10n.ComicMissingIssues.count, summary.missingCount))
                    .font(.title3.weight(.black))
                    .foregroundStyle(ComicTheme.ink)

                if summary.missingCount > 0 {
                    Text(summary.displayText)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(ComicTheme.ink.opacity(0.72))
                        .lineLimit(3)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .comicPanel(fill: ComicTheme.yellow)
    }
}
