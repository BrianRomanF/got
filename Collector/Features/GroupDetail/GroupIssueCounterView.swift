import SwiftUI

struct GroupIssueCounterView: View {
    let itemTitle: String
    let ownedCount: Int
    let totalCount: Int

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .font(.title3.weight(.black))
                .foregroundStyle(ComicTheme.green)

            VStack(alignment: .leading, spacing: 3) {
                Text(itemTitle.uppercased().vintageSafe)
                    .font(.caption.weight(.black))
                    .foregroundStyle(ComicTheme.ink.opacity(0.75))

                Text(String(format: L10n.GroupDetail.issueCounter, ownedCount, totalCount))
                    .font(.title2.weight(.black))
                    .foregroundStyle(ComicTheme.ink)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .comicPanel(fill: ComicTheme.yellow)
    }
}
