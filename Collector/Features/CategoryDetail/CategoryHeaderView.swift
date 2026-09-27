import SwiftUI

struct CategoryHeaderView: View {
    let category: CollectionCategory

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            CategoryIconView(category: category, size: 76, symbolSize: 42)

            VStack(alignment: .leading, spacing: 5) {
                Text(category.title.uppercased())
                    .font(ComicTheme.displayFont)
                    .foregroundStyle(ComicTheme.ink)
                    .lineLimit(2)
                    .minimumScaleFactor(0.65)

                Text(category.subtitle)
                    .font(ComicTheme.bodyFont)
                    .foregroundStyle(ComicTheme.ink.opacity(0.75))
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .comicPanel(fill: ComicTheme.panel)
    }
}
