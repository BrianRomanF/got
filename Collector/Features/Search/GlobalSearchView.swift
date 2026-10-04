import SwiftUI

struct GlobalSearchView: View {
    @EnvironmentObject private var libraryController: CollectionLibraryController
    @State private var query = ""

    private var results: [GlobalSearchResult] {
        libraryController.globalSearchResults(query: query)
    }

    var body: some View {
        ZStack {
            HalftoneBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(L10n.GlobalSearch.title.uppercased().vintageSafe)
                            .font(ComicTheme.titleFont)
                            .foregroundStyle(ComicTheme.ink)

                        Text(L10n.GlobalSearch.subtitle)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(ComicTheme.ink.opacity(0.68))
                    }

                    GlobalSearchBar(text: $query)

                    if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        ComicEmptyStateView(
                            systemName: "magnifyingglass",
                            title: L10n.GlobalSearch.startTitle,
                            message: L10n.GlobalSearch.startMessage
                        )
                    } else if results.isEmpty {
                        ComicEmptyStateView(
                            systemName: "questionmark.folder.fill",
                            title: L10n.Empty.searchTitle,
                            message: L10n.Empty.searchMessage
                        )
                    } else {
                        LazyVStack(spacing: 14) {
                            ForEach(results) { result in
                                NavigationLink(value: result.route) {
                                    GlobalSearchResultCell(result: result)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle(L10n.GlobalSearch.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(ComicTheme.paper, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)
    }
}
