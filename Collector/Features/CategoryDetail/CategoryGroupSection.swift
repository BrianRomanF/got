import SwiftUI

struct CategoryGroupSection: View {
    let category: CollectionCategory

    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 16)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(category.template.topLevelGroupTitle.uppercased())
                .font(ComicTheme.titleFont)
                .foregroundStyle(ComicTheme.ink)

            if category.groups.isEmpty {
                ComicEmptyStateView(
                    systemName: "tray.full.fill",
                    title: L10n.Empty.shelvesTitle,
                    message: L10n.Empty.shelvesMessage
                )
            } else {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(category.groups) { group in
                        NavigationLink(value: CollectorRoute.group(categoryID: category.id, groupID: group.id)) {
                            CategoryGroupCell(group: group)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}
