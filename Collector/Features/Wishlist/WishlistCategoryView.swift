import SwiftUI

struct WishlistCategoryView: View {
    @EnvironmentObject private var libraryController: CollectionLibraryController
    @State private var searchText = ""
    let categoryID: UUID

    var body: some View {
        ZStack {
            HalftoneBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    ComicSheetHeader(
                        title: categoryTitle,
                        subtitle: L10n.Wishlist.categorySubtitle
                    )

                    WishlistSearchBar(text: $searchText)

                    if filteredSections.isEmpty {
                        ComicEmptyStateView(
                            systemName: "magnifyingglass",
                            title: searchText.isEmpty ? L10n.Wishlist.emptyTitle : L10n.Empty.searchTitle,
                            message: searchText.isEmpty ? L10n.Wishlist.emptyMessage : L10n.Empty.searchMessage
                        )
                    } else {
                        LazyVStack(spacing: 14) {
                            ForEach(filteredSections) { section in
                                NavigationLink(value: CollectorRoute.wishlistSection(sectionID: section.id)) {
                                    WishlistFolderCell(section: section)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private var categoryTitle: String {
        libraryController.category(with: categoryID)?.title ?? L10n.Wishlist.title
    }

    private var filteredSections: [WishlistSection] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let sections = libraryController.wishlistSections(inCategory: categoryID)

        guard !query.isEmpty else { return sections }

        return sections.filter { section in
            section.title.lowercased().contains(query)
                || section.entries.contains { entry in
                    entry.item.title.lowercased().contains(query)
                        || entry.item.subtitle.lowercased().contains(query)
                }
        }
    }
}
