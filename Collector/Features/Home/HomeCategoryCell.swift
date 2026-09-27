import SwiftUI

struct HomeCategoryCell: View {
    let category: CollectionCategory

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            CategoryIconView(category: category, size: 58, symbolSize: 34)

            VStack(alignment: .leading, spacing: 4) {
                Text(category.title.uppercased())
                    .font(.system(.headline, design: .rounded).weight(.black))
                    .foregroundStyle(ComicTheme.ink)
                    .lineLimit(2)

                Text(category.subtitle)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(ComicTheme.ink.opacity(0.72))
                    .lineLimit(2)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, minHeight: 170, alignment: .topLeading)
        .padding(14)
        .comicPanel(fill: ComicTheme.panel)
    }
}
