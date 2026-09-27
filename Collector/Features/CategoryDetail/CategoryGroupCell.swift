import SwiftUI

struct CategoryGroupCell: View {
    let group: CollectionGroup

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: "square.stack.3d.up.fill")
                .font(.title.weight(.black))
                .foregroundStyle(ComicTheme.blue)

            Text(group.title.uppercased())
                .font(.headline.weight(.black))
                .foregroundStyle(ComicTheme.ink)
                .lineLimit(2)

            if !group.subtitle.isEmpty {
                Text(group.subtitle)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(ComicTheme.ink.opacity(0.68))
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 130, alignment: .topLeading)
        .padding(14)
        .comicPanel(fill: ComicTheme.yellow)
    }
}
