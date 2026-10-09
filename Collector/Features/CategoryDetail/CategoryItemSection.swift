import SwiftUI

struct CategoryItemSection: View {
    let category: CollectionCategory
    let items: [CollectibleItem]
    let displayMode: ItemDisplayMode
    let isSelecting: Bool
    let selectedItemIDs: Set<UUID>
    let onAddItem: () -> Void
    let onToggleSelected: (CollectibleItem) -> Void
    let onEditItem: (CollectibleItem) -> Void
    let onToggleOwnership: (CollectibleItem) -> Void
    let onDeleteItem: (CollectibleItem) -> Void

    private let columns = [
        GridItem(.adaptive(minimum: 130), spacing: 16)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(category.template.itemTitle.uppercased().vintageSafe)
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
                        itemContent(item) {
                            CategoryItemCell(item: item)
                        }
                    }
                }
            } else {
                LazyVStack(spacing: 14) {
                    ForEach(items) { item in
                        itemContent(item) {
                            ItemGalleryCell(item: item)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func itemContent<Content: View>(_ item: CollectibleItem, @ViewBuilder content: () -> Content) -> some View {
        if isSelecting {
            Button {
                onToggleSelected(item)
            } label: {
                content()
                    .overlay(alignment: .topLeading) {
                        SelectionBadge(isSelected: selectedItemIDs.contains(item.id))
                            .padding(8)
                    }
            }
            .buttonStyle(.plain)
        } else {
            NavigationLink(value: CollectorRoute.item(categoryID: category.id, groupID: nil, itemID: item.id)) {
                content()
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

private struct SelectionBadge: View {
    let isSelected: Bool

    var body: some View {
        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
            .font(.title3.weight(.black))
            .foregroundStyle(isSelected ? ComicTheme.green : ComicTheme.ink.opacity(0.7))
            .background(Color.white.clipShape(Circle()))
    }
}
