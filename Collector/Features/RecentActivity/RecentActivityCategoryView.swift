import SwiftUI

struct RecentActivityCategoryView: View {
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
                        subtitle: L10n.RecentActivity.categorySubtitle
                    )

                    WishlistSearchBar(text: $searchText)

                    if filteredSections.isEmpty {
                        ComicEmptyStateView(
                            systemName: "clock.badge.questionmark.fill",
                            title: searchText.isEmpty ? L10n.RecentActivity.emptyTitle : L10n.Empty.searchTitle,
                            message: searchText.isEmpty ? L10n.RecentActivity.emptyMessage : L10n.Empty.searchMessage
                        )
                    } else {
                        LazyVStack(spacing: 14) {
                            ForEach(filteredSections) { section in
                                NavigationLink(value: CollectorRoute.recentActivitySection(sectionID: section.id)) {
                                    RecentActivityFolderCell(section: section)
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
        libraryController.category(with: categoryID)?.title ?? L10n.RecentActivity.title
    }

    private var filteredSections: [RecentActivitySection] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let sections = libraryController.recentActivitySections(inCategory: categoryID)

        guard !query.isEmpty else { return sections }

        return sections.filter { section in
            matches(query, in: [section.title])
                || section.entries.contains { entry in
                    matches(query, in: [entry.item.title, entry.item.subtitle, entry.item.notes, entry.item.physicalLocation ?? ""])
                }
        }
    }

    private func matches(_ query: String, in values: [String]) -> Bool {
        values.contains { value in
            value.range(of: query, options: [.caseInsensitive, .diacriticInsensitive]) != nil
        }
    }
}
