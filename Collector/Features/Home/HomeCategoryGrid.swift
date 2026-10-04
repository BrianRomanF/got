import SwiftUI

struct HomeCategoryGrid: View {
    let categories: [CollectionCategory]
    let stats: (CollectionCategory) -> CollectionStats
    let onEdit: (CollectionCategory) -> Void
    let onDelete: (CollectionCategory) -> Void

    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 18)
    ]

    var body: some View {
        if categories.isEmpty {
            ComicEmptyStateView(
                systemName: "square.grid.2x2.fill",
                title: L10n.Empty.collectionsTitle,
                message: L10n.Empty.collectionsMessage
            )
        } else {
            LazyVGrid(columns: columns, spacing: 18) {
                ForEach(categories) { category in
                    NavigationLink(value: CollectorRoute.category(category.id)) {
                        HomeCategoryCell(category: category, stats: stats(category))
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button {
                            onEdit(category)
                        } label: {
                            Label(L10n.Home.editCategory, systemImage: "pencil")
                        }

                        Button(role: .destructive) {
                            onDelete(category)
                        } label: {
                            Label(L10n.Home.deleteCategory, systemImage: "trash.fill")
                        }
                    }
                }
            }
        }
    }
}
