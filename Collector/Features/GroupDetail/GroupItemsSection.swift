import SwiftUI

struct GroupItemsSection: View {
    let categoryID: UUID
    let groupID: UUID
    let itemTitle: String
    let items: [CollectibleItem]
    let displayMode: ItemDisplayMode
    let onAddItem: () -> Void
    let onEditItem: (CollectibleItem) -> Void
    let onToggleOwnership: (CollectibleItem) -> Void
    let onDeleteItem: (CollectibleItem) -> Void

    private let columns = [
        GridItem(.adaptive(minimum: 130), spacing: 16)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(itemTitle.uppercased().vintageSafe)
                .font(ComicTheme.titleFont)
                .foregroundStyle(ComicTheme.ink)

            if items.isEmpty {
                ComicEmptyActionView(
                    systemName: "photo.on.rectangle.angled",
                    title: L10n.Empty.piecesTitle,
                    message: L10n.Empty.piecesMessage,
                    actionTitle: L10n.Detail.addItem,
                    actionSystemName: "plus.square.fill",
                    action: onAddItem
                )
            } else if displayMode == .grid {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(items) { item in
                        NavigationLink(value: CollectorRoute.item(categoryID: categoryID, groupID: groupID, itemID: item.id)) {
                            GroupItemCell(item: item)
                        }
                        .buttonStyle(.plain)
                        .itemQuickActions(
                            item: item,
                            onEdit: { onEditItem(item) },
                            onToggleOwnership: { onToggleOwnership(item) },
                            onDelete: { onDeleteItem(item) }
                        )
                    }
                }
            } else {
                LazyVStack(spacing: 14) {
                    ForEach(items) { item in
                        NavigationLink(value: CollectorRoute.item(categoryID: categoryID, groupID: groupID, itemID: item.id)) {
                            ItemGalleryCell(item: item)
                        }
                        .buttonStyle(.plain)
                        .itemQuickActions(
                            item: item,
                            onEdit: { onEditItem(item) },
                            onToggleOwnership: { onToggleOwnership(item) },
                            onDelete: { onDeleteItem(item) }
                        )
                    }
                }
            }
        }
    }
}
