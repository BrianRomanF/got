import SwiftUI

struct WishlistView: View {
    @EnvironmentObject private var libraryController: CollectionLibraryController
    @State private var searchText = ""
    @State private var selectedTag = ""

    private var availableTags: [String] {
        libraryController.wishlistEntries()
            .flatMap { $0.item.tags }
            .reduce(into: [String]()) { result, tag in
                guard !result.contains(where: { $0.compare(tag, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame }) else { return }
                result.append(tag)
            }
            .sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
    }

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
                    WishlistTagFilter(selectedTag: $selectedTag, tags: availableTags)

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

        guard !query.isEmpty || !selectedTag.isEmpty else { return summaries }

        return summaries.compactMap { summary in
            let sections = summary.sections.filter { section in
                let matchesQuery = query.isEmpty
                    || summary.title.lowercased().contains(query)
                    || section.title.lowercased().contains(query)
                    || section.entries.contains { entry in
                        entry.item.title.lowercased().contains(query)
                            || entry.item.subtitle.lowercased().contains(query)
                            || entry.item.notes.lowercased().contains(query)
                            || entry.item.tags.contains { $0.lowercased().contains(query) }
                }

                let matchesTag = selectedTag.isEmpty || section.entries.contains { entry in
                    entry.item.tags.contains { $0.compare(selectedTag, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame }
                }

                return matchesQuery && matchesTag
            }

            guard !sections.isEmpty else { return nil }
            return WishlistCategorySummary(id: summary.id, title: summary.title, sections: sections)
        }
    }
}

private struct WishlistTagFilter: View {
    @Binding var selectedTag: String
    let tags: [String]

    var body: some View {
        if !tags.isEmpty {
            Menu {
                Button(L10n.GlobalSearch.allTags) {
                    selectedTag = ""
                }

                ForEach(tags, id: \.self) { tag in
                    Button {
                        selectedTag = tag
                    } label: {
                        Label(tag, systemImage: selectedTag == tag ? "checkmark" : "tag")
                    }
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "tag.fill")
                        .foregroundStyle(ComicTheme.red)

                    Text((selectedTag.isEmpty ? L10n.GlobalSearch.allTags : selectedTag).uppercased())
                        .font(.caption.weight(.black))
                        .foregroundStyle(ComicTheme.ink)

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption.weight(.black))
                        .foregroundStyle(ComicTheme.ink.opacity(0.6))
                }
                .padding(14)
                .comicPanel(fill: .white)
            }
        }
    }
}
