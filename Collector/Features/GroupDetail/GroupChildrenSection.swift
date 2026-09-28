import SwiftUI

struct GroupChildrenSection: View {
    let categoryID: UUID
    let groups: [CollectionGroup]

    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 16)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.Detail.groups.uppercased().vintageSafe)
                .font(ComicTheme.titleFont)
                .foregroundStyle(ComicTheme.ink)

            if groups.isEmpty {
                ComicEmptyStateView(
                    systemName: "tray.full.fill",
                    title: L10n.Empty.shelvesTitle,
                    message: L10n.Empty.shelvesMessage
                )
            } else {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(groups) { group in
                        NavigationLink(value: CollectorRoute.group(categoryID: categoryID, groupID: group.id)) {
                            GroupChildCell(group: group)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}
