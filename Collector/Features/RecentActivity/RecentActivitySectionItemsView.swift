import SwiftUI

struct RecentActivitySectionItemsView: View {
    @EnvironmentObject private var libraryController: CollectionLibraryController
    @State private var searchText = ""
    let sectionID: String

    var body: some View {
        ZStack {
            HalftoneBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    if let section = libraryController.recentActivitySection(with: sectionID) {
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
                                    NavigationLink(value: entry.route) {
                                        RecentActivityCell(entry: entry)
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

    private func filteredEntries(from section: RecentActivitySection) -> [RecentActivityEntry] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return section.entries }

        return section.entries.filter { entry in
            matches(query, in: [
                entry.item.title,
                entry.item.subtitle,
                entry.item.notes,
                entry.item.physicalLocation ?? ""
            ])
        }
    }

    private func matches(_ query: String, in values: [String]) -> Bool {
        values.contains { value in
            value.range(of: query, options: [.caseInsensitive, .diacriticInsensitive]) != nil
        }
    }
}
