import SwiftUI

struct WishlistView: View {
    @EnvironmentObject private var libraryController: CollectionLibraryController
    @State private var searchText = ""

    var body: some View {
        ZStack {
            HalftoneBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    ComicSheetHeader(
                        title: L10n.Wishlist.title,
                        subtitle: L10n.Wishlist.subtitle
                    )

                    WishlistSearchBar(text: $searchText)

                    let summaries = filteredSummaries
                    if summaries.isEmpty {
                        ComicEmptyStateView(
                            systemName: "checkmark.seal.fill",
                            title: searchText.isEmpty ? L10n.Wishlist.emptyTitle : L10n.Empty.searchTitle,
                            message: searchText.isEmpty ? L10n.Wishlist.emptyMessage : L10n.Empty.searchMessage
                        )
                    } else {
                        LazyVStack(spacing: 14) {
                            ForEach(summaries) { summary in
                                NavigationLink(value: CollectorRoute.wishlistCategory(summary.id)) {
                                    WishlistCategoryCell(summary: summary)
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

    private var filteredSummaries: [WishlistCategorySummary] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let summaries = libraryController.wishlistCategorySummaries()

        guard !query.isEmpty else { return summaries }

        return summaries.compactMap { summary in
            let sections = summary.sections.filter { section in
                summary.title.lowercased().contains(query)
                    || section.title.lowercased().contains(query)
                    || section.entries.contains { entry in
                        entry.item.title.lowercased().contains(query)
                            || entry.item.subtitle.lowercased().contains(query)
                }
            }

            guard !sections.isEmpty else { return nil }
            return WishlistCategorySummary(id: summary.id, title: summary.title, sections: sections)
        }
    }
}
