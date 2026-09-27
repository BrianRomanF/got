import SwiftUI

struct GroupHeaderView: View {
    let group: CollectionGroup

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(group.title.uppercased())
                .font(ComicTheme.displayFont)
                .foregroundStyle(ComicTheme.ink)
                .lineLimit(3)
                .minimumScaleFactor(0.65)

            if !group.subtitle.isEmpty {
                Text(group.subtitle)
                    .font(ComicTheme.bodyFont)
                    .foregroundStyle(ComicTheme.ink.opacity(0.72))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .comicPanel(fill: ComicTheme.yellow)
    }
}
