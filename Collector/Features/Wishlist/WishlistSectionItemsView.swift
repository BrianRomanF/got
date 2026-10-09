import SwiftUI

struct WishlistSectionItemsView: View {
    @EnvironmentObject private var libraryController: CollectionLibraryController
    @State private var searchText = ""
    let sectionID: String

    var body: some View {
        ZStack {
            HalftoneBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    if let section = libraryController.wishlistSection(with: sectionID) {
                        ComicSheetHeader(
                            title: section.title,
                            subtitle: section.categoryTitle
                        )

                        WishlistSearchBar(text: $searchText)

                        let entries = filteredEntries(from: section)
                        if entries.isEmpty {
                            ComicEmptyStateView(
                                systemName: "magnifyingglass",
                                title: L10n.Empty.searchTitle,
                                message: L10n.Empty.searchMessage
                            )
                        } else {
                            LazyVStack(spacing: 14) {
                                ForEach(entries) { entry in
                                    NavigationLink(value: CollectorRoute.item(categoryID: entry.categoryID, groupID: entry.groupID, itemID: entry.item.id)) {
                                        WishlistEntryCell(entry: entry)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
                .padding(20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func filteredEntries(from section: WishlistSection) -> [WishlistEntry] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return section.entries }

        return section.entries.filter { entry in
            entry.item.title.lowercased().contains(query)
                || entry.item.subtitle.lowercased().contains(query)
                || entry.item.notes.lowercased().contains(query)
                || entry.item.tags.contains { $0.lowercased().contains(query) }
        }
    }
}
