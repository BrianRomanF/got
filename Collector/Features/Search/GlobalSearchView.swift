import SwiftUI

struct GlobalSearchView: View {
    @EnvironmentObject private var libraryController: CollectionLibraryController
    @State private var query = ""
    @State private var selectedKind: GlobalSearchFilterKind = .all
    @State private var selectedTag = ""

    private var results: [GlobalSearchResult] {
        libraryController.globalSearchResults(
            query: query,
            allowedKinds: selectedKind.allowedKinds,
            tag: selectedTag.isEmpty ? nil : selectedTag
        )
    }

    private var availableTags: [String] {
        libraryController.allTags()
    }

    private var hasSearchInput: Bool {
        !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !selectedTag.isEmpty
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
                    GlobalSearchFiltersView(
                        selectedKind: $selectedKind,
                        selectedTag: $selectedTag,
                        tags: availableTags
                    )

                    if !hasSearchInput {
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

enum GlobalSearchFilterKind: String, CaseIterable, Identifiable, Hashable {
    case all
    case categories
    case shelves
    case pieces

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all:
            L10n.GlobalSearch.filterAll
        case .categories:
            L10n.GlobalSearch.filterCategories
        case .shelves:
            L10n.GlobalSearch.filterShelves
        case .pieces:
            L10n.GlobalSearch.filterPieces
        }
    }

    var allowedKinds: Set<GlobalSearchResultKind> {
        switch self {
        case .all:
            Set(GlobalSearchResultKind.allCases)
        case .categories:
            [.category]
        case .shelves:
            [.shelf]
        case .pieces:
            [.piece]
        }
    }
}

private struct GlobalSearchFiltersView: View {
    @Binding var selectedKind: GlobalSearchFilterKind
    @Binding var selectedTag: String
    let tags: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(L10n.GlobalSearch.filtersTitle.uppercased(), systemImage: "line.3.horizontal.decrease.circle.fill")
                    .font(.caption.weight(.black))
                    .foregroundStyle(ComicTheme.ink.opacity(0.72))

                Spacer(minLength: 0)

                if selectedKind != .all || !selectedTag.isEmpty {
                    Button(L10n.GlobalSearch.clearFilters) {
                        selectedKind = .all
                        selectedTag = ""
                    }
                    .font(.caption.weight(.black))
                    .foregroundStyle(ComicTheme.red)
                }
            }

            ComicSegmentedControl(
                options: GlobalSearchFilterKind.allCases,
                selection: $selectedKind,
                title: { $0.title }
            )

            if !tags.isEmpty {
                Menu {
                    Button(L10n.GlobalSearch.allTags) {
                        selectedTag = ""
                    }

                    ForEach(tags, id: \.self) { tag in
                        Button {
                            selectedTag = tag
                            selectedKind = .pieces
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
                            .lineLimit(1)

                        Spacer(minLength: 0)

                        Image(systemName: "chevron.up.chevron.down")
                            .font(.caption.weight(.black))
                            .foregroundStyle(ComicTheme.ink.opacity(0.6))
                    }
                    .padding(12)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 7)
                            .stroke(ComicTheme.ink, lineWidth: 2)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 7))
                }
            }
        }
        .padding(14)
        .comicPanel(fill: ComicTheme.paper)
    }
}
