import SwiftUI

struct CategoryItemSection: View {
    let category: CollectionCategory
    let items: [CollectibleItem]

    private let columns = [
        GridItem(.adaptive(minimum: 130), spacing: 16)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(category.template.itemTitle.uppercased())
                .font(ComicTheme.titleFont)
                .foregroundStyle(ComicTheme.ink)

            if items.isEmpty {
                ComicEmptyStateView(
                    systemName: "photo.on.rectangle.angled",
                    title: L10n.Empty.piecesTitle,
                    message: L10n.Empty.piecesMessage
                )
            } else {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(items) { item in
                        NavigationLink(value: CollectorRoute.item(categoryID: category.id, groupID: nil, itemID: item.id)) {
                            CategoryItemCell(item: item)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}
