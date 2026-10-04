import SwiftUI

struct RecentActivityView: View {
    @EnvironmentObject private var libraryController: CollectionLibraryController
    @State private var searchText = ""

    private var summaries: [RecentActivityCategorySummary] {
        let summaries = libraryController.recentActivityCategorySummaries()
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else { return summaries }

        return summaries.compactMap { summary in
            let sections = summary.sections.filter { section in
                matches(query, in: [summary.title, section.title])
                    || section.entries.contains { entry in
                        matches(query, in: [
                            entry.item.title,
                            entry.item.subtitle,
                            entry.item.notes,
                            entry.item.physicalLocation ?? ""
                        ])
                    }
            }

            guard !sections.isEmpty else { return nil }
            return RecentActivityCategorySummary(id: summary.id, title: summary.title, sections: sections)
        }
    }

    var body: some View {
        ZStack {
            HalftoneBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(L10n.RecentActivity.title.uppercased().vintageSafe)
                            .font(ComicTheme.titleFont)
                            .foregroundStyle(ComicTheme.ink)

                        Text(L10n.RecentActivity.subtitle)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(ComicTheme.ink.opacity(0.68))
                    }

                    WishlistSearchBar(text: $searchText)

                    if summaries.isEmpty {
                        ComicEmptyStateView(
                            systemName: "clock.badge.questionmark.fill",
                            title: searchText.isEmpty ? L10n.RecentActivity.emptyTitle : L10n.Empty.searchTitle,
                            message: searchText.isEmpty ? L10n.RecentActivity.emptyMessage : L10n.Empty.searchMessage
                        )
                    } else {
                        LazyVStack(spacing: 14) {
                            ForEach(summaries) { summary in
                                NavigationLink(value: CollectorRoute.recentActivityCategory(summary.id)) {
                                    RecentActivityCategoryCell(summary: summary)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle(L10n.RecentActivity.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(ComicTheme.paper, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)
    }

    private func matches(_ query: String, in values: [String]) -> Bool {
        values.contains { value in
            value.range(of: query, options: [.caseInsensitive, .diacriticInsensitive]) != nil
        }
    }
}
